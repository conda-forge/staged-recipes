#include <libdivide.h>
#include <stdint.h>
int main(void) {
    for (int32_t d = -17; d <= 17; ++d) {
        if (d == 0) continue;
        struct libdivide_s32_t fast = libdivide_s32_gen(d);
        for (int32_t n = -1000; n <= 1000; ++n)
            if (libdivide_s32_do(n, &fast) != n / d) return 1;
    }
    return 0;
}
