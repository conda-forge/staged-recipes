sed -i '/CXX_STD = CXX14/a CXX14 = g++ -std=c++11' %SRC_DIR%/Makevars.win
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
