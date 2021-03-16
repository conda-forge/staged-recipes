copy /B gdal_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B ogr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B osr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B gdalconst_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy  apps/*.cs %SCRIPTS%
if errorlevel 1 exit 1

copy  const/*.cs %SCRIPTS%
if errorlevel 1 exit 1

copy  gdal/*.cs %SCRIPTS%
if errorlevel 1 exit 1

copy  ogr/*.cs %SCRIPTS%
if errorlevel 1 exit 1

copy  osr/*.cs %SCRIPTS%
if errorlevel 1 exit 1