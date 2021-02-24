#include <sciplot/sciplot.hpp>
using namespace sciplot;

int main(int argc, char** argv)
{
    // Create values for your x-axis
    Vec x = linspace(0.0, 5.0, 100);

    // Create a Plot object
    Plot plot;

    // Set color palette
    plot.palette("set2");

    // Draw a sine graph putting x on the x-axis and sin(x) on the y-axis
    plot.drawCurve(x, std::sin(x)).label("sin(x)").lineWidth(4);

    // Draw a cosine graph putting x on the x-axis and cos(x) on the y-axis
    plot.drawCurve(x, std::cos(x)).label("cos(x)").lineWidth(4);
}
