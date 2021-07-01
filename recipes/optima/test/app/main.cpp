#include <Optima/Optima.hpp>
using namespace Optima;

int main(int argc, char **argv)
{
    // Solve the following problem:
    // min( (x-1)**2 + (y-1)**2 ) subject to x = y and x,y >= 0

    Dims dims;
    dims.x = 2; // number of variables
    dims.be = 1; // number of linear equality constraints

    Problem problem(dims);
    problem.Aex = Matrix{{ {1.0, -1.0} }};
    problem.be = Vector{{ 0.0 }};
    problem.f = [](ObjectiveResultRef res, VectorView x, VectorView p, VectorView c, ObjectiveOptions opts)
    {
        res.f = (x[0] - 1)*(x[0] - 1) + (x[1] - 1)*(x[1] - 1);
        res.fx = 2.0 * (x - 1);
        res.fxx = 2.0 * identity(2, 2);
    };

    State state(dims);

    Options options;
    options.output.active = true;

    Solver solver;
    solver.setOptions(options);

    solver.solve(problem, state);

    std::cout << state.x << std::endl;
}
