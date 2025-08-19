#include <folly/memory/Arena.h>
#include <folly/lang/ToAscii.h>

int main() {
  static const size_t requestedBlockSize = 64;
  folly::SysArena arena(requestedBlockSize);
  size_t* ptr = static_cast<size_t*>(arena.allocate(sizeof(long)));
  arena.deallocate(ptr, 0 /* unused */);
  return 0;
}
