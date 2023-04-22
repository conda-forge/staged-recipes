if not exist %PREFIX%/tmp mkdir %PREFIX%/tmp

"%R%" CMD INSTALL --build . %R_ARGS%
if errorlevel 1 exit 1
