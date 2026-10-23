#include <eden/common/utils/PathFuncs.h>

int main() {
  auto path = facebook::eden::canonicalPath("/conda/forge/../watchman");
  return path.view() == "/conda/watchman" ? 0 : 1;
}
