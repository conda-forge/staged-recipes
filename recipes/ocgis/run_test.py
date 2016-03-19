import os
from ocgis.test import run_simple

# Set GDAL_DATA. This is done normally done by the activate script,
# but this doesn't happen in the testing environment.
if 'LIBRARY_PREFIX' in os.environ:  # Windows.
    gdalData = os.path.join(os.environ['LIBRARY_PREFIX'], 'share', 'gdal')
else:  # Linux/OS X.
    gdalData = os.path.join(os.environ['PREFIX'], 'share', 'gdal')

os.environ['GDAL_DATA'] = gdalData

run_simple()
