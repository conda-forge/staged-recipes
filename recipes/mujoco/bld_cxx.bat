set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DMUJOCO_BUILD_TESTS:BOOL=ON ^
    -DMUJOCO_BUILD_EXAMPLES:BOOL=OFF ^
    -DMUJOCO_ENABLE_AVX:BOOL=OFF ^
    -DMUJOCO_ENABLE_AVX_INTRINSICS:BOOL=OFF ^
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
