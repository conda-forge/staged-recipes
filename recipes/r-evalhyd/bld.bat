if not exist %PREFIX%/tmp mkdir %PREFIX%/tmp

bash %RECIPE_DIR%/build_win.sh
if errorlevel 1 exit 1

set PKG_CXXFLAGS=-I"%LIBRARY_INC%" && "%R%" CMD INSTALL --build . %R_ARGS%
if errorlevel 1 exit 1
