"""
This is based on os1_hw.py found in the original recipe in the OSGEO channel.

http://www.gis.usu.edu/~chrisg/python/2008/os1_hw.py

"""

import os
import ogr

# Set the working directory and file names.
fname = os.path.join(os.environ['RECIPE_DIR'], 'test_data', 'sites.shp')

# Open the output file.

# Open the data source.
driver = ogr.GetDriverByName('ESRI Shapefile')
data_source = driver.Open(fname, 0)
assert data_source is not None, 'Could not open {}'.format(fname)

# Get the layer and loop through the features.
layer = data_source.GetLayer()
feature = layer.GetNextFeature()
while feature:
    # Get the attributes.
    feature_id = feature.GetFieldAsString('id')
    cover = feature.GetFieldAsString('cover')

    # Get the point coordinates.
    geometry = feature.GetGeometryRef()
    x = geometry.GetX()
    y = geometry.GetY()

    # Print the info.
    print('{} {} {} {}\n'.format(feature_id, x, y, cover))

    # Get the next feature.
    feature.Destroy()
    feature = layer.GetNextFeature()

# Close the data source and file.
data_source.Destroy()
