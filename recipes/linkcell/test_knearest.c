#include "linkcell.h"

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N_BIG 4096
#define K_BIG 6
#define SIDE 16.0
#define STAGE0_CHUNKS 64
#define STAGE1_CHUNKS 32

static double uniform(uint64_t *state) {
  *state = *state * 6364136223846793005ULL + 1442695040888963407ULL;
  return (double)(*state >> 11) * (1.0 / 9007199254740992.0);
}

static double periodic_d2(const double *a, const double *b) {
  double d2 = 0.0;
  for (int c = 0; c < 3; ++c) {
    double d = a[c] - b[c];
    d -= SIDE * floor(d / SIDE + 0.5);
    d2 += d * d;
  }
  return d2;
}

/* The k nearest of point i by direct search, nearest first. */
static void brute_row(const double *xyz, size_t n, size_t i, size_t k,
                      int *row) {
  double best[K_BIG];
  for (size_t t = 0; t < k; ++t) {
    best[t] = INFINITY;
    row[t] = -1;
  }
  for (size_t j = 0; j < n; ++j) {
    if (j == i) {
      continue;
    }
    double d2 = periodic_d2(xyz + 3 * i, xyz + 3 * j);
    if (d2 >= best[k - 1]) {
      continue;
    }
    size_t t = k - 1;
    while (t > 0 && best[t - 1] > d2) {
      best[t] = best[t - 1];
      row[t] = row[t - 1];
      --t;
    }
    best[t] = d2;
    row[t] = (int)j;
  }
}

static int lists(const int *nn, size_t k, size_t i, int j) {
  for (size_t t = 0; t < k; ++t) {
    if (nn[i * k + t] == j) {
      return 1;
    }
  }
  return 0;
}

struct cols {
  int *data;
  size_t total;
};

static int *alloc_cols(void *ctx, size_t total) {
  struct cols *c = ctx;
  c->data = malloc(total * sizeof(int) + 1);
  c->total = total;
  return c->data;
}

/* Row i of the CSR graph holds exactly the j that pass the edge rule. */
static int check_csr(const int *nn, size_t n, size_t k, int mutual,
                     const int *offsets, const struct cols *c) {
  if (offsets[0] != 0 || (size_t)offsets[n] != c->total) {
    fprintf(stderr, "csr mutual=%d offsets %d..%d total %zu\n", mutual,
            offsets[0], offsets[n], c->total);
    return 1;
  }
  size_t expected_total = 0;
  for (size_t i = 0; i < n; ++i) {
    size_t expected = 0;
    for (size_t j = 0; j < n; ++j) {
      if (j == i) {
        continue;
      }
      int fwd = lists(nn, k, i, (int)j);
      int back = lists(nn, k, j, (int)i);
      if (mutual ? (fwd && back) : (fwd || back)) {
        ++expected;
      }
    }
    expected_total += expected;
    if (offsets[i + 1] < offsets[i] ||
        (size_t)(offsets[i + 1] - offsets[i]) != expected) {
      fprintf(stderr, "csr mutual=%d row %zu degree %d expected %zu\n", mutual,
              i, offsets[i + 1] - offsets[i], expected);
      return 1;
    }
    for (int e = offsets[i]; e < offsets[i + 1]; ++e) {
      int j = c->data[e];
      if (j < 0 || (size_t)j >= n || (size_t)j == i) {
        fprintf(stderr, "csr mutual=%d row %zu column %d\n", mutual, i, j);
        return 1;
      }
      int fwd = lists(nn, k, i, j);
      int back = lists(nn, k, (size_t)j, (int)i);
      if (mutual ? !(fwd && back) : !(fwd || back)) {
        fprintf(stderr, "csr mutual=%d row %zu has stray edge %d\n", mutual, i,
                j);
        return 1;
      }
      for (int f = offsets[i]; f < e; ++f) {
        if (c->data[f] == j) {
          fprintf(stderr, "csr mutual=%d row %zu repeats %d\n", mutual, i, j);
          return 1;
        }
      }
    }
  }
  if (expected_total != c->total) {
    fprintf(stderr, "csr mutual=%d total %zu expected %zu\n", mutual, c->total,
            expected_total);
    return 1;
  }
  return 0;
}

struct stages {
  int stage0[STAGE0_CHUNKS];
  int stage1[STAGE1_CHUNKS];
  size_t worker0[STAGE0_CHUNKS];
  size_t worker1[STAGE1_CHUNKS];
  size_t width;
};

static void run_chunk(void *ctx, size_t stage, size_t chunk, size_t worker) {
  struct stages *s = ctx;
  if (stage == 0) {
    s->worker0[chunk] = worker;
    s->stage0[chunk] += 1;
    return;
  }
  s->worker1[chunk] = worker;
  /* Every chunk of stage 0 has returned before stage 1 starts. */
  int seen = 0;
  for (size_t c = 0; c < STAGE0_CHUNKS; ++c) {
    seen += s->stage0[c];
  }
  s->stage1[chunk] = seen;
}

static int check_team(void) {
  struct stages s;
  memset(&s, 0, sizeof s);
  s.width = lc_team_width();
  if (s.width == 0) {
    fprintf(stderr, "team width 0\n");
    return 1;
  }
  const size_t chunks[2] = {STAGE0_CHUNKS, STAGE1_CHUNKS};
  if (lc_team_run(2, chunks, run_chunk, &s) != 0) {
    fprintf(stderr, "lc_team_run: %s\n", lc_last_error());
    return 1;
  }
  for (size_t c = 0; c < STAGE0_CHUNKS; ++c) {
    if (s.worker0[c] >= s.width) {
      fprintf(stderr, "stage 0 chunk %zu on worker %zu\n", c, s.worker0[c]);
      return 1;
    }
    if (s.stage0[c] != 1) {
      fprintf(stderr, "stage 0 chunk %zu ran %d times\n", c, s.stage0[c]);
      return 1;
    }
  }
  for (size_t c = 0; c < STAGE1_CHUNKS; ++c) {
    if (s.worker1[c] >= s.width) {
      fprintf(stderr, "stage 1 chunk %zu on worker %zu\n", c, s.worker1[c]);
      return 1;
    }
    if (s.stage1[c] != STAGE0_CHUNKS) {
      fprintf(stderr, "stage 1 chunk %zu saw %d of stage 0\n", c, s.stage1[c]);
      return 1;
    }
  }
  printf("team width %zu\n", s.width);
  return 0;
}

int main(void) {
  const char *version = lc_version();
  const double xyz[] = {0.0, 0.0, 0.0, 1.0, 0.0, 0.0};
  const size_t n = 2;
  const size_t k = 1;
  const lc_cell box = lc_cell_ortho(10.0, 10.0, 10.0);
  int out[2];

  if (version == NULL || version[0] == '\0') {
    return 1;
  }
  printf("%s\n", version);
  if (lc_knearest(xyz, n, &box, k, NULL, 0.0, out) != 0) {
    fprintf(stderr, "%s\n", lc_last_error());
    return 1;
  }
  /* Each point's nearest neighbour is the other point. */
  if (out[0] != 1 || out[1] != 0) {
    fprintf(stderr, "neighbours %d %d\n", out[0], out[1]);
    return 1;
  }

  /* Enough points that the search runs on the worker team. */
  double *big = malloc(3 * N_BIG * sizeof(double));
  int *nn = malloc(N_BIG * K_BIG * sizeof(int));
  int *offsets = malloc((N_BIG + 1) * sizeof(int));
  if (big == NULL || nn == NULL || offsets == NULL) {
    return 1;
  }
  uint64_t state = 20261123u;
  for (size_t i = 0; i < 3 * N_BIG; ++i) {
    big[i] = SIDE * uniform(&state);
  }
  const lc_cell big_box = lc_cell_ortho(SIDE, SIDE, SIDE);
  printf("threads %d\n", lc_num_threads());
  if (lc_knearest(big, N_BIG, &big_box, K_BIG, NULL, 0.0, nn) != 0) {
    fprintf(stderr, "lc_knearest: %s\n", lc_last_error());
    return 1;
  }
  for (size_t i = 0; i < N_BIG; ++i) {
    int row[K_BIG];
    brute_row(big, N_BIG, i, K_BIG, row);
    for (size_t t = 0; t < K_BIG; ++t) {
      if (nn[i * K_BIG + t] != row[t]) {
        fprintf(stderr, "point %zu slot %zu: %d, direct search %d\n", i, t,
                nn[i * K_BIG + t], row[t]);
        return 1;
      }
    }
  }

  for (int mutual = 0; mutual <= 1; ++mutual) {
    struct cols c = {NULL, 0};
    if (lc_knearest_csr(big, N_BIG, &big_box, K_BIG, NULL, 0.0, mutual,
                        offsets, alloc_cols, &c) != 0) {
      fprintf(stderr, "lc_knearest_csr: %s\n", lc_last_error());
      return 1;
    }
    if (c.data == NULL || check_csr(nn, N_BIG, K_BIG, mutual, offsets, &c)) {
      return 1;
    }
    printf("csr mutual=%d edges %zu\n", mutual, c.total);
    free(c.data);
  }

  if (check_team()) {
    return 1;
  }
  free(offsets);
  free(nn);
  free(big);
  return 0;
}
