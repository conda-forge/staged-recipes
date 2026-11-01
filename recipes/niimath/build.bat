@echo on

:: Same configuration as build.sh. MSVC builds are single-threaded upstream,
:: so there is no OpenMP to enable here.
cmake -S src -B build ^
    -G Ninja ^
    --no-warn-unused-cli ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DZLIB_IMPLEMENTATION:STRING=System ^
    -DCMAKE_VERBOSE_MAKEFILE=ON ^
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=ON ^
    -DUSE_STATIC_RUNTIME:BOOL=OFF ^
    %CMAKE_ARGS%
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
