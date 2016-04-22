#!/usr/bin/env python
"""
Main test harness for RIOS. 

Should be run as a main program. It then runs a selection 
of tests of some capabilities of RIOS. 

"""
# Set GDAL_DATA. This is done normally done by the activate script,
# but this doesn't happen in the testing environment
import os
if 'LIBRARY_PREFIX' in os.environ:
    # Windows
    gdalData = os.path.join(os.environ['LIBRARY_PREFIX'], 'share', 'gdal')
else:
    # Linux/OSX
    gdalData = os.path.join(os.environ['PREFIX'], 'share', 'gdal')

os.environ['GDAL_DATA'] = gdalData

if __name__ == '__main__':
    # this if is important since some of the tests use the multiprocessing module
    from rios.riostests import riostestutils
    riostestutils.testAll()
