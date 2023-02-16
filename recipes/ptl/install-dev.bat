cd build
if errorlevel 1 exit /b 1

cmake --install .
if errorlevel 1 exit /b 1
