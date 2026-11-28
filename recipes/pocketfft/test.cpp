// Real FFT of a cosine on a length whose half is prime (Bluestein path), plus a
// complex round trip through the public N-D API.
#include <pocketfft_hdronly.h>

#include <cmath>
#include <complex>
#include <cstdio>
#include <vector>

int main() {
  const double pi = std::acos(-1.0);
  const std::size_t n = 2 * 10007;
  std::vector<double> x(n);
  for (std::size_t i = 0; i < n; ++i) {
    x[i] = std::cos(2.0 * pi * 3.0 * static_cast<double>(i) / static_cast<double>(n));
  }
  std::vector<std::complex<double>> spectrum(n / 2 + 1);
  pocketfft::r2c<double>({n}, {sizeof(double)}, {sizeof(std::complex<double>)}, 0, pocketfft::FORWARD, x.data(),
                         spectrum.data(), 1.0, 1);
  const double peak = std::abs(spectrum[3]);
  std::printf("|X[3]| = %.9f (expected %.1f)\n", peak, static_cast<double>(n) / 2.0);
  if (std::abs(peak - static_cast<double>(n) / 2.0) > 1e-6 * static_cast<double>(n)) {
    return 1;
  }

  std::vector<std::complex<float>> c(64), back(64);
  for (std::size_t i = 0; i < c.size(); ++i) {
    c[i] = {static_cast<float>(i), -static_cast<float>(i)};
  }
  pocketfft::c2c<float>({c.size()}, {sizeof(std::complex<float>)}, {sizeof(std::complex<float>)}, {0},
                        pocketfft::FORWARD, c.data(), back.data(), 1.0f, 1);
  pocketfft::c2c<float>({c.size()}, {sizeof(std::complex<float>)}, {sizeof(std::complex<float>)}, {0},
                        pocketfft::BACKWARD, back.data(), back.data(), 1.0f / static_cast<float>(c.size()), 1);
  for (std::size_t i = 0; i < c.size(); ++i) {
    if (std::abs(back[i] - c[i]) > 1e-3f) {
      std::printf("round trip mismatch at %zu\n", i);
      return 1;
    }
  }
  std::puts("ok");
  return 0;
}
