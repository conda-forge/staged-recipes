#include <google/cloud/version.h>
#include <iostream>

int main() {
  std::cout << "Hello: " << google::cloud::version_string() << "\n";
  return 0;
}
