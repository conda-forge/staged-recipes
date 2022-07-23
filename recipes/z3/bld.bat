mkdir build
cd build
cmake %CMAKE_ARGS% ^
    ..
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
