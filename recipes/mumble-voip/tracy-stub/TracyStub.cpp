// Stub implementations of Tracy profiler symbols used unconditionally by mumble.
// When TRACY_ENABLE is not defined, Tracy.hpp still declares these as external
// symbols but does not provide inline definitions.

#include <cstdint>

namespace tracy {

void SetThreadName(const char*) {}

} // namespace tracy
