:: Ensure our geos will be used.
rem  rmdir %SRC_DIR%\geos-3.3.3 /s /q || exit 1  !!FIXME!!
rem  set GEOS_DIR=%LIBRARY_PREFIX%

"%PYTHON%" setup.py install
if errorlevel 1 exit 1

:: Remove the data from the site-packages directory.
rmdir %SP_DIR%\mpl_toolkits\basemap\data /s /q || exit 1

:: Create the data directory.
set DATADIR="%PREFIX%\share\basemap"

:: Copy all the data.
copy %SRC_DIR%\lib\mpl_toolkits\basemap\data\ %DATADIR%

:: But remove the high resolution data. (Packaged separately.)
rmdir %DATADIR%\*_h.dat
rmdir %DATADIR%\*_f.dat
