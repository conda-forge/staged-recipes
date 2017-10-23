mkdir %LIBRARY_INC%\cspice

cd %SRC_DIR%\src\cspice

makeDynamicSpice.bat

copy "cspice.dll" %LIBRARY_LIB%

cd %SRC_DIR%

copy "include\\*.h" %LIBRARY_INC%\cspice

if errorlevel 1 exit 1
