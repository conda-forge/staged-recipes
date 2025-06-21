@echo on

:: configure
cmake ^
    -S %SRC_DIR% -B build                   ^
    %CMAKE_ARGS%                            ^
    -G "Ninja"                              ^
    -DCMAKE_BUILD_TYPE=Release              ^
    -DCMAKE_INSTALL_LIBDIR=lib              ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_VERBOSE_MAKEFILE=ON
if errorlevel 1 exit 1

:: build
cmake --build build --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build build --config Release --target install
if errorlevel 1 exit 1

:: test
ctest --test-dir build --build-config Release --output-on-failure
if errorlevel 1 exit 1

