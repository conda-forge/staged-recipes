import matplotlib
matplotlib.use('agg')

from mpl_toolkits.basemap import Basemap

m = Basemap(projection='ortho', lat_0=45, lon_0=-100, resolution='c')
