#include <nanobench.h>

int main() {
    int value = 0;
    ankerl::nanobench::Bench().performanceCounters(false).run("smoke", [&] {
        ankerl::nanobench::doNotOptimizeAway(++value);
    });
    return value == 0;
}
