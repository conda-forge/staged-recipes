import matplotlib
matplotlib.use('agg')

from mpl_toolkits.basemap import Basemap

# Test the new data.
m = Basemap(projection='ortho', lat_0=45, lon_0=-100, resolution='i')
m.drawcounties()

# Test the data that should be there already.
m = Basemap(projection='ortho', lat_0=45, lon_0=-100, resolution='c')
m.drawcounties()
