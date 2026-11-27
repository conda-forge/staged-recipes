#include <XAD/XAD.hpp>
#include <cmath>
#include <iostream>

int main()
{
    using mode = xad::adj<double>;
    using AD = mode::active_type;

    mode::tape_type tape;
    AD x0 = 1.0, x1 = 1.5;
    tape.registerInput(x0);
    tape.registerInput(x1);
    tape.newRecording();

    AD y = x0 * x1 + sin(x0);
    tape.registerOutput(y);
    derivative(y) = 1.0;
    tape.computeAdjoints();

    std::cout << "XAD " << XAD_VERSION_STRING << ": dy/dx0 = " << derivative(x0)
              << ", dy/dx1 = " << derivative(x1) << "\n";
    bool ok = std::abs(derivative(x0) - (1.5 + std::cos(1.0))) < 1e-12 &&
              std::abs(derivative(x1) - 1.0) < 1e-12;
    return ok ? 0 : 1;
}
