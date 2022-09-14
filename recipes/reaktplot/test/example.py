from reaktplot import *

x = list(range(5))
y = [xi**2 for xi in x]

fig = Figure()

fig.titleText("SQUARE FUNCTION")

fig.xaxisTitleText("x")
fig.yaxisTitleText("y")

fig.addScatter(x, y, "x**2")

fig.save("xsquared.pdf")
