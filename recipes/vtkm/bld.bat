mkdir build
cd build

set BUILD_CONFIG=Release

cmake .. -G "Ninja" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE:STRING="%BUILD_CONFIG%" ^
    -DVTKm_ENABLE_CUDA:BOOL=OFF ^
    -DVTKm_USE_64BIT_IDS:BOOL=OFF ^
    -DVTKm_USE_DOUBLE_PRECISION:BOOL=OFF ^
    -DVTKm_ENABLE_BENCHMARKS:BOOL=OFF ^
    -DVTKm_ENABLE_TBB:BOOL=ON ^

if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1
