findstr /V "CXX_STD" Makevars.win > Makevars.win
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
