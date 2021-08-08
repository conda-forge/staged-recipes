setlocal EnableDelayedExpansion

mkdir build
cd build

cmake $CMAKE_ARGS -G Ninja ^ 
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_CXX_STANDARD:STRING=17 ^
    -DCMAKE_INSTALL_PREFIX:STRING="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DANTS_SUPERBUILD:BOOL=OFF ^
    -DITK_USE_SYSTEM_FFTW:BOOL=ON ^
    -DRUN_LONG_TESTS=OFF ^
    -DRUN_SHORT_TESTS=ON ^
    -DUSE_SYSTEM_ITK:BOOL=ON ^
    -DUSE_SYSTEM_VTK:BOOL=ON ^
    ..
if errorlevel 1 exit 1

cmake --build .
if errorlevel 1 exit 1

ctest --extra-verbose --output-on-failure .
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
