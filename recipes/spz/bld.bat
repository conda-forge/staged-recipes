@echo on
@setlocal EnableDelayedExpansion

cmake -S %SRC_DIR% -B build -G "Ninja" ^
    -D CMAKE_BUILD_TYPE:STRING=Release ^
    -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -D CMAKE_VERBOSE_MAKEFILE:BOOL=%CMAKE_VERBOSE_MAKEFILE% ^
    -D BUILD_SHARED_LIBS:BOOL=ON ^
    -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
     %CMAKE_ARGS%
if errorlevel 1 exit 1

cmake --build build -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1



