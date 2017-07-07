GEOIPDATADIR=%LIBRARY_PREFIX%
INSTDIR=%LIBRARY_PREFIX%

nmake /f Makefile.vc
nmake /f Makefile.vc test
nmake /f Makefile.vc install