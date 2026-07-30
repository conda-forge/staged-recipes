cmake -S "%SRC_DIR%\c" -B build ^
    -GNinja ^
    %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit 1

cmake --build build -j %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
