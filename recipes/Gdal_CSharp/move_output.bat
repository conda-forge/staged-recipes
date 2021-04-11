copy /B gdal_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B ogr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B osr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B gdalconst_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

mkdir %PREFIX%\Library\share\%PKG_NAME%
if errorlevel exit 1

copy apps\*.cs %PREFIX%\Library\share\%PKG_NAME%
if errorlevel 1 exit 1

copy  const\*.cs %PREFIX%\Library\share\%PKG_NAME%
if errorlevel 1 exit 1

copy  gdal\*.cs %PREFIX%\Library\share\%PKG_NAME%
if errorlevel 1 exit 1

copy  ogr\*.cs %PREFIX%\Library\share\%PKG_NAME%
if errorlevel 1 exit 1

copy  osr\*.cs %PREFIX%\Library\share\%PKG_NAME%
if errorlevel 1 exit 1