set "CXX14FLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function  -Wno-macro-redefined"
set "CXX14=g++ -std=c++1y -fPIC" 
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
