// Plot a parabola and save it as PNG
#include <QApplication>
#include <qcustomplot.h>

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);
	QCustomPlot plot;
	QVector<double> x(101), y(101);
	for (int i = 0; i < 101; ++i)
	{
		x[i] = i / 50.0 - 1;
		y[i] = x[i] * x[i];
	}
	plot.addGraph();
	plot.graph(0)->setData(x, y);
	plot.rescaleAxes();
	return plot.savePng("plot.png", 200, 150) ? 0 : 1;
}
