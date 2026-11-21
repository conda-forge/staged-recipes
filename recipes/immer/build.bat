cmake -S . -B cmake-build -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -Dimmer_BUILD_TESTS=OFF ^
    -Dimmer_BUILD_EXAMPLES=OFF ^
    -Dimmer_BUILD_DOCS=OFF ^
    -Dimmer_BUILD_EXTRAS=OFF
if errorlevel 1 exit /b 1
cmake --build cmake-build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
cmake --install cmake-build
if errorlevel 1 exit /b 1
