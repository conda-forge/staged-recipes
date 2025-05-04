:: Clean and create build directory
if exist build rmdir /s /q build
mkdir build
cd build

:: Configure with CMake
cmake -GNinja ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBOX2D_BUILD_DOCS=OFF ^
    -DBOX2D_SAMPLES=OFF ^
    "%SRC_DIR%"
if errorlevel 1 exit 1

:: Build
cmake --build . -j %CPU_COUNT%
if errorlevel 1 exit 1

:: Install
cmake --build . --target install
if errorlevel 1 exit 1
