setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1
cmake . ^
    -DCMAKE_INSTALL_PREFIX=$PREFIX$ ^
    -DCMAKE_CXX_EXTENSIONS=OFF ^
    -S %SRC_DIR% ^
    -B build ^
    -DARBORX_ENABLE_MPI=OFF ^
    %CMAKE_ARGS$ ^
    %CUDA_ARGS% :: only for CUDA-enabled Kokkos
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1
cmake --install .
if errorlevel 1 exit 1
