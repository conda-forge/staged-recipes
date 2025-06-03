:: Clean and create build directory
if exist build rmdir /s /q build
mkdir build
cd build


:: Configure with CMake
cmake -GNinja ^
    %CMAKE_ARGS% ^
    -DENKITS_BUILD_SHARED=ON ^
    -DENKITS_BUILD_C_INTERFACE=ON ^
    -DENKITS_BUILD_EXAMPLES=OFF ^
    -DENKITS_INSTALL=ON ^
    -DENKITS_SANITIZE=OFF ^
    "%SRC_DIR%"
if errorlevel 1 exit 1

:: Build
cmake --build . -j %CPU_COUNT%
if errorlevel 1 exit 1

:: Install
cmake --build . --target install
if errorlevel 1 exit 1