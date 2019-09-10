import numpy as np
from pygeos import box, area, intersection

polygons_x = box(range(5), 0, range(10, 15), 10)
polygons_y = box(0, range(5), 10, range(10, 15))

area(intersection(polygons_x[:, np.newaxis], polygons_y[np.newaxis, :]))

