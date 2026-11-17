#include "linkcell.h"

#include <stdio.h>
#include <stdlib.h>

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
  return 0;
}
