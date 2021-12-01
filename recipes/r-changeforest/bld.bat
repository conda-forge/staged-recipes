"%R%" CMD INSTALL --build changeforest-r %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit 1
