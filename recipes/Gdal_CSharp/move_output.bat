copy /B gdal_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B ogr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B osr_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B gdalconst_*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

echo %PREFIX%
echo copy apps to "%PREFIX%\Scripts"

copy apps\*.cs "%REFIX%\Scripts"
if errorlevel 1 exit 1

copy  const\*.cs "%REFIX%\Scripts"
if errorlevel 1 exit 1

copy  gdal\*.cs "%REFIX%\Scripts"
if errorlevel 1 exit 1

copy  ogr\*.cs "%REFIX%\Scripts"
if errorlevel 1 exit 1

copy  osr\*.cs "%REFIX%\Scripts"
if errorlevel 1 exit 1