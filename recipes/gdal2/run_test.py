import osgeo._gdal
import osgeo._gdalconst
import osgeo._ogr
import osgeo._osr
import osgeo
import gdal
import gdalconst
import ogr
import osr

cnt = ogr.GetDriverCount()
for i in range(cnt):
    print(ogr.GetDriver(i).GetName())

import os1_hw

def has_geos():
    pnt1 = ogr.CreateGeometryFromWkt( 'POINT(10 20)' )
    pnt2 = ogr.CreateGeometryFromWkt( 'POINT(30 20)' )
    ogrex = ogr.GetUseExceptions()
    ogr.DontUseExceptions()
    hasgeos = pnt1.Union( pnt2 ) is not None
    if ogrex:
        ogr.UseExceptions()
    return hasgeos

if not has_geos():
  print('GEOS not available within GDAL')
  sys.exit(1)
