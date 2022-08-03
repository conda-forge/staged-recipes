setlocal EnableDelayedExpansion

mkdir build
cd build
if errorlevel 1 exit 1

cmake ^
-GNinja ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
-DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
-DBUILD_SHARED_LIBS=ON ^
%CMAKE_ARGS% ^
-DKokkos_ENABLE_OPENMP=ON ^
-DKokkos_ENABLE_EXAMPLES=OFF ^
-DKokkos_ENABLE_SERIAL=ON ^
%Kokkos_OPT_ARGS% ^
%Kokkos_CUDA_ARGS% ^
%Kokkos_TEST_ARGS% ^
-S %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . -j %CPU_COUNT%
if errorlevel 1 exit 1

:: Tests will take approximately 8 minutes
ctest --output-on-failure
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
