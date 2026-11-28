cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_DISABLE_TESTING=ON ^
    -DZIP_BUILD_TOOLS=OFF ^
    -DZIP_BUILD_DOCS=OFF ^
    -DZIP_BUILD_FUZZ=OFF
if errorlevel 1 exit /b 1
cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
cmake --install build
if errorlevel 1 exit /b 1
