#include <array>
#include <iostream>

#include "Quartic/PolynomialRoots.hh"


int main() {
  const auto coeffs = std::array<double, 6>{ 8, -8, 16,-16, 8,-8 }; // polynomial coeffs

  auto zeror = std::array<double, 5>{};
  auto zeroi = std::array<double, 5>{};

  auto degree = 5;

  auto ok = PolynomialRoots::roots(coeffs.data(), degree, zeror.data(), zeroi.data()); // ok < 0 failed
  std::cout << " ok = " << ok << '\n';
  for (auto i = 0 ; i < degree ; ++i) {
    std::cout << zeror[i] << " + I* " << zeroi[i] << '\n';
  }
}
