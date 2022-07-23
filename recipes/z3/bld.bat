mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DCMAKE_C_COMPILER=%CC% ^
    -DCMAKE_CXX_COMPILER=%CXX% ^
    ..
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
