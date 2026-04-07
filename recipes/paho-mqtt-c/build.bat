cmake %CMAKE_ARGS% ^
    -Bbuild ^
    -H. ^
    -GNinja ^
    -DPAHO_ENABLE_TESTING=OFF ^
    -DPAHO_WITH_SSL=ON ^
    -DPAHO_HIGH_PERFORMANCE=ON ^
    -DPAHO_BUILD_SHARED=ON ^
    -DPAHO_BUILD_STATIC=OFF ^
    -DPAHO_BUILD_DOCUMENTATION=OFF ^
    -DPAHO_BUILD_SAMPLES=OFF
if errorlevel 1 exit 1

cmake --build build --target install
if errorlevel 1 exit 1
