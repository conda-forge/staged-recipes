:: Configure.
cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX=%PREFIX% .
if errorlevel 1 exit 1

:: Build.
make
if errorlevel 1 exit 1

:: Install.
make install
if errorlevel 1 exit 1
