# http://www.gis.usu.edu/~chrisg/python/2008/os1_hw.py
# os1_hw.py
# Solution to Open Source week 1 homework -- reading vector data
# cgarrard 1-31-08

import sys
import ogr

# Set the working directory and filenames.
# os.chdir('d:/data/classes/python/os1')
dataFn = 'sites.shp'
outFn = 'sites_coords.txt'

# Open the output file.
outFile = open(outFn, 'w')

# Open the data source.
driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(dataFn, 0)
if dataSource is None:
    print('Could not open ' + dataFn)
    sys.exit(1)

# Get the layer and loop through the features.
layer = dataSource.GetLayer()
feature = layer.GetNextFeature()
while feature:
    # Get the attributes.
    id = feature.GetFieldAsString('id')
    cover = feature.GetFieldAsString('cover')

    # Get the point coordinates.
    geometry = feature.GetGeometryRef()
    x = geometry.GetX()
    y = geometry.GetY()

    # Print the info.
    outFile.write(id + ' ' + str(x) + ' ' + str(y) + ' ' + cover + '\n')

    # Get the next feature.
    feature.Destroy()
    feature = layer.GetNextFeature()

# Close the data source and file.
dataSource.Destroy()
outFile.close()

print("END os1_hw.py")
