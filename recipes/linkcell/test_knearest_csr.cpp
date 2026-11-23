#include "linkcell.hpp"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>

namespace {

constexpr std::size_t kPoints = 2048;
constexpr std::size_t kNearest = 4;
constexpr double kSide = 13.0;

int *grow(void *ctx, std::size_t total) {
  auto *cols = static_cast<std::vector<int> *>(ctx);
  cols->assign(total, -1);
  return cols->data();
}

int fail(const char *what) {
  std::fprintf(stderr, "%s\n", what);
  return 1;
}

} // namespace

int main() {
  std::vector<std::array<double, 3>> xyz(kPoints);
  std::uint64_t state = 0x5eedu;
  for (auto &p : xyz) {
    for (double &x : p) {
      state = state * 6364136223846793005ULL + 1442695040888963407ULL;
      x = kSide * static_cast<double>(state >> 11) * (1.0 / 9007199254740992.0);
    }
  }
  const auto cell = linkcell::Cell::ortho(kSide, kSide, kSide);
  const lc_cell raw = cell.raw();

  const linkcell::Neighbours nn = linkcell::knearest(xyz, cell, kNearest);
  std::vector<int> c_nn(kPoints * kNearest, -1);
  if (lc_knearest(xyz.front().data(), kPoints, &raw, kNearest, nullptr, 0.0,
                  c_nn.data()) != 0) {
    return fail("lc_knearest failed");
  }
  for (std::size_t i = 0; i < kPoints; ++i) {
    for (std::size_t t = 0; t < kNearest; ++t) {
      if (nn.neighbour(i, t) != c_nn[i * kNearest + t]) {
        return fail("linkcell::knearest differs from lc_knearest");
      }
      if (t > 0 && nn.dist2(i, t) < nn.dist2(i, t - 1)) {
        return fail("neighbours are not nearest first");
      }
    }
  }

  for (const bool mutual : {false, true}) {
    std::vector<int> offsets;
    std::vector<int> cols;
    linkcell::knearest_csr(xyz.front().data(), kPoints, cell, kNearest, mutual,
                           offsets, cols);
    std::vector<int> c_offsets(kPoints + 1, -1);
    std::vector<int> c_cols;
    if (lc_knearest_csr(xyz.front().data(), kPoints, &raw, kNearest, nullptr,
                        0.0, mutual ? 1 : 0, c_offsets.data(), grow,
                        &c_cols) != 0) {
      return fail("lc_knearest_csr failed");
    }
    if (offsets != c_offsets || cols != c_cols) {
      return fail("linkcell::knearest_csr differs from lc_knearest_csr");
    }
    if (offsets.size() != kPoints + 1 ||
        static_cast<std::size_t>(offsets.back()) != cols.size()) {
      return fail("CSR offsets do not cover the columns");
    }
    std::printf("csr mutual=%d edges %zu\n", mutual ? 1 : 0, cols.size());
  }

  try {
    std::vector<int> offsets;
    std::vector<int> cols;
    linkcell::knearest_csr(xyz.front().data(), kPoints, cell, 0, false,
                           offsets, cols);
    return fail("k = 0 did not throw");
  } catch (const linkcell::Error &) {
  }
  std::printf("%s\n", lc_version());
  return 0;
}
