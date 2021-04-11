copy /B gdal_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B ogr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B osr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B gdalconst_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B *.exe %LIBRARY_BIN%