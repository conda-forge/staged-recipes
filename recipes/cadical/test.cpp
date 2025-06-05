#include <cadical.hpp>
#include <cassert>

int main() {
    CaDiCaL::Solver solver;
    solver.add(1);
    solver.add(0);
    int res = solver.solve();
    assert(res == 10);
    res = solver.val(1);
    assert(res > 0);
    return 0;
}
