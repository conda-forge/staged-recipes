#include <libdivide.h>
#include <cstdint>
int main() {
    for (int64_t d = -17; d <= 17; ++d) {
        if (d == 0) continue;
        libdivide::divider<int64_t> fast(d);
        for (int64_t n = -1000; n <= 1000; ++n)
            if (n / fast != n / d) return 1;
    }
    return 0;
}
