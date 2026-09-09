// Compile-and-run check: Blitz++ 1.0.2 dates from 2019, so the point of this
// test is to prove its headers still work under a current C++ toolchain, not
// just that files landed in $PREFIX.
#include <blitz/array.h>
#include <iostream>

int main() {
    blitz::Array<double, 2> a(3, 3);
    a = 1.0;
    a(1, 1) = 5.0;

    const double total = blitz::sum(a);
    std::cout << "blitz sum = " << total << std::endl;

    // 8 cells of 1.0 plus the single 5.0
    return (total == 13.0) ? 0 : 1;
}
