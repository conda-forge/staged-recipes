// C++ includes
#include <cmath>
#include <cassert>
using namespace std;

// autodiff includes
#include <autodiff/forward.hpp>
using namespace autodiff;

dual f(dual x)
{
    return x*x;
}

int main()
{
    dual x = 2.0;
    dual u = f(x);

    double dudx = derivative(f, wrt(x), x);

    assert(abs(dudx - 4.0) < 1e-14);
}
