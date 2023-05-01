if not exist %PREFIX%/tmp mkdir %PREFIX%/tmp

set PKG_CXXFLAGS=-I"%LIBRARY_INC%" --std="c++14" && "%R%" CMD INSTALL --build . %R_ARGS%
if errorlevel 1 exit 1
