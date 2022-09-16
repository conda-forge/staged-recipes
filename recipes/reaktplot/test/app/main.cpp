#include <reaktplot/reaktplot.hpp>
using namespace reaktplot;

int main(int argc, char** argv)
{
    Array x = linspace(0.0, PI, 200);

    Figure fig;

    fig.titleText("SINE FUNCTION");

    fig.xaxisTitleText("x");
    fig.yaxisTitleText("y");

    fig.addScatter(x, Array(std::sin(1.0 * x)), "sin(x)");

    fig.save("sine.pdf");
}
