"%R%" CMD INSTALL --install-tests --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
