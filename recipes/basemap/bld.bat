:: Ensure our geos will be used.
set GEOS_DIR=%LIBRARY_PREFIX%
rmdir %SRC_DIR%\geos-3.3.3 /s /q || exit 1

"%PYTHON%" setup.py install
if errorlevel 1 exit 1

:: Remove the data from the site-packages directory.
rmdir %SP_DIR%\mpl_toolkits\basemap\data /s /q || exit 1

:: Create the data directory.
set DATADIR="%LIBRARY_PREFIX%\share\basemap"
mkdir %DATADIR% || exit 1

:: Copy all the data.
xcopy %SRC_DIR%\lib\mpl_toolkits\basemap\data\* %DATADIR% /s /e || exit 1

:: But remove the high resolution data. (Packaged separately.)
del %DATADIR%\*_i.dat
del %DATADIR%\*_h.dat
del %DATADIR%\*_f.dat
del %DATADIR%\UScounties.*
del %DATADIR%\test27
del %DATADIR%\test83
del %DATADIR%\testntv2
del %DATADIR%\testvarious
