"%R%" CMD INSTALL --configure-args CXXFLAGS='CXX14 = g++ -std=c++11' --build .
IF %ERRORLEVEL% NEQ 0 exit 1
