REM Avoid the the message printed to stderr about what problems are found
REM which confuses py6s
set FFLAGS="-ffpe-summary=none"

set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: Configure.
cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% .
if errorlevel 1 exit 1

:: Build.
mingw32-make
if errorlevel 1 exit 1

:: Install.
mingw32-make install
if errorlevel 1 exit 1
