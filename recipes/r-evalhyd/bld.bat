"%R%" CMD INSTALL --build . %R_ARGS%
if errorlevel 1 exit 1
