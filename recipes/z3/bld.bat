mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DCMAKE_C_COMPILER=%CC% ^
    -DCMAKE_CXX_COMPILER=%CXX% ^
    -DCMAKE_GENERATOR_PLATFORM= ^
    -DCMAKE_GENERATOR_TOOLSET= ^
    ..
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
