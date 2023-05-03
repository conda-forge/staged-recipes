if not exist %PREFIX%/tmp mkdir %PREFIX%/tmp

set PKG_CXXFLAGS=-I"%LIBRARY_INC%" && "%R%" CMD INSTALL --build . %R_ARGS%
if errorlevel 1 exit 1
