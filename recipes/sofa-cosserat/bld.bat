setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
cmake ^
    %CMAKE_ARGS% ^
    -B . ^
    -S %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DPYTHON_EXECUTABLE=$CONDA_PREFIX/bin/python ^
    -DPython_FIND_STRATEGY=LOCATION ^
    -DCOSSERATPLUGIN_BUILD_TESTS=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: Test
ctest --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1