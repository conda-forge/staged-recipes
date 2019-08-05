findstr /V "CXX_STD" src/Makevars.win > src/Makevars.win
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
