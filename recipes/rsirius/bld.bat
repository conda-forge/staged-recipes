"%R%" CMD INSTALL --build ./client-api_r/generated
IF %ERRORLEVEL% NEQ 0 exit 1