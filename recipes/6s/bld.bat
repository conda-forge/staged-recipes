move C:/Program Files/Git/usr/bin/sh.exe C:/Program Files/Git/usr/bin/shOLD.exe

:: Configure.
cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX=%PREFIX% .
if errorlevel 1 exit 1

:: Build.
make
if errorlevel 1 exit 1

:: Install.
make install
if errorlevel 1 exit 1
