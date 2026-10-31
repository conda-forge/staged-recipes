cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
    -DBUILD_TESTING=OFF
if errorlevel 1 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build
if errorlevel 1 exit /b 1
