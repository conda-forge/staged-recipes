from shapely import speedups;

assert speedups.available;

speedups.enable()

from shapely.geometry import LineString

ls = LineString([(0, 0), (10, 0)])
# On OSX causes an abort trap, due to https://github.com/Toblerity/Shapely/issues/177 
r = ls.wkt
area = ls.buffer(10).area

