sed -i -e "s/void R_init_gdalraster/__declspec(dllexport) void R_init_gdalraster/" src/RcppExports.cpp

"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
