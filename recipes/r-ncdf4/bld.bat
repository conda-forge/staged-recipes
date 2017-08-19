set LIBRARY_LIB=%LIBRARY_LIB:\=/%
set LIBRARY_INC=%LIBRARY_INC:\=/%

"%R%" CMD INSTALL --build .
if errorlevel 1 exit 1
