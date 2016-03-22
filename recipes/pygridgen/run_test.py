import pygridgen
x = [0, 1, 2, 1, 0]
y = [0, 0, 1, 2, 2]
beta = [1, 1, 0, 1, 1]

focus = pygridgen.grid.Focus()
focus.add_focus_x(xo=0.5, factor=3, Rx=0.2)
focus.add_focus_y(yo=0.75, factor=5, Ry=0.1)
grid = pygridgen.grid.Gridgen(x, y, beta, shape=(20, 20), focus=focus)
