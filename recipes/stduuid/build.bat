cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DUUID_BUILD_TESTS=OFF ^
    -DUUID_ENABLE_INSTALL=ON ^
    -DUUID_SYSTEM_GENERATOR=OFF ^
    -DUUID_TIME_GENERATOR=OFF ^
    -DUUID_USING_CXX20_SPAN=OFF
if errorlevel 1 exit /b 1
cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
cmake --install build
if errorlevel 1 exit /b 1
