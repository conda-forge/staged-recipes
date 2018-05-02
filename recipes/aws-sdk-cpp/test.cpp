#include <aws/core/Version.h>
#include <iostream>

int main() {
  std::cout << Aws::Version::GetVersionString() << std::endl;
  return 0;
}
