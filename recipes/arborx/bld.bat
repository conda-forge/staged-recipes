setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1

cmake %CMAKE_ARGS% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
    -DCMAKE_CXX_EXTENSIONS=OFF ^
    -B build ^
    -DARBORX_ENABLE_MPI=OFF ^
    -S %SRC_DIR%

if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
