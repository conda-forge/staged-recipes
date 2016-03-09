# http://www.gis.usu.edu/~chrisg/python/2008/os1_hw.py
# os1_hw.py
# Solution to Open Source week 1 homework -- reading vector data
# cgarrard 1-31-08

import ogr, sys, os

# set the working directory and filenames
# os.chdir('d:/data/classes/python/os1')
dataFn = 'sites.shp'
outFn = 'sites_coords.txt'

# open the output file
outFile = open(outFn, 'w')

# open the datasource
driver = ogr.GetDriverByName('ESRI Shapefile')
dataSource = driver.Open(dataFn, 0)
if dataSource is None:
  print('Could not open ' + dataFn)
  sys.exit(1)

# get the layer and loop through the features
layer = dataSource.GetLayer()
feature = layer.GetNextFeature()
while feature:

  # get the attributes
  id = feature.GetFieldAsString('id')
  cover = feature.GetFieldAsString('cover')

  # get the point coordinates
  geometry = feature.GetGeometryRef()
  x = geometry.GetX()
  y = geometry.GetY()

  # print the info
  outFile.write(id + ' ' + str(x) + ' ' + str(y) + ' ' + cover + '\n')

  # get the next feature
  feature.Destroy()
  feature = layer.GetNextFeature()

# close the datasource and file
dataSource.Destroy()
outFile.close()

print("END os1_hw.py")
