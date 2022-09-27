"%R%" CMD INSTALL --build . --configure-vars='INCLUDE_DIR="%INCLUDE%" LIB_DIR="%LIB%"'
IF %ERRORLEVEL% NEQ 0 exit /B 1
