#include <lyra/lyra.hpp>

#include <iostream>

int main(int argc, const char *argv[]) {
  int arg = 0;
  auto cli = lyra::cli() | lyra::opt(arg, "arg")["-arg"];
  auto result = cli.parse({argc, argv});
  if (!result) {
    std::cerr << "Error in command line: " << result.errorMessage() << "\n";
    return 1;
  }
  std::cout << "arg=" << arg << "\n";
  return 0;
}
