SET GEOIPDATADIR=%LIBRARY_PREFIX%\share\GeoIP
SET INSTDIR=%LIBRARY_PREFIX%

nmake /f Makefile.vc
nmake /f Makefile.vc test
nmake /f Makefile.vc install

copy