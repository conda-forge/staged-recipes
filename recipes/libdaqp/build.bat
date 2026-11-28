:: the shared library alone: conda-forge ships no static library
cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DDAQP_BUILD_SHARED=ON ^
    -DDAQP_BUILD_STATIC=OFF ^
    -DDAQP_CMAKE_INSTALL_DIR=lib/cmake/daqp
if %ERRORLEVEL% neq 0 exit 1

cmake --build build --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install build
if %ERRORLEVEL% neq 0 exit 1
