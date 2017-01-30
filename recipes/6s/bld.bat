set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: Configure.
cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX=%PREFIX% .
if errorlevel 1 exit 1

:: Build.
mingw-make
if errorlevel 1 exit 1

:: Install.
mingw-make install
if errorlevel 1 exit 1
