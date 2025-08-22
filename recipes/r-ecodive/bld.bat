"%R%" CMD INSTALL --configure-args="CFLAGS=-pthread" --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
