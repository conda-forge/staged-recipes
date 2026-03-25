@echo ON

cmake -B build/ ^
    -G "Ninja" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D SPARROW_IPC_BUILD_SHARED=ON ^
    -D SPARROW_IPC_BUILD_TESTS=OFF ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    %SRC_DIR%

if errorlevel 1 exit 1
cmake --build build/ --parallel %CPU_COUNT%
if errorlevel 1 exit 1
cmake --install build/
if errorlevel 1 exit 1

