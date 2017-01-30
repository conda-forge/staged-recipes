set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: Configure.
cmake -G "MinGW Makefiles" -D CMAKE_INSTALL_PREFIX=%PREFIX% .
if errorlevel 1 exit 1

:: Build.
mingw32-make
if errorlevel 1 exit 1

:: Install.
mingw32-make install
if errorlevel 1 exit 1

sixs < Example_In_1.txt
