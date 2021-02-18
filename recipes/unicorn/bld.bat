@echo on

mkdir build
if errorlevel 1 exit 1

cmake ^
    -G "Ninja" ^
    -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -S source -B build
if errorlevel 1 exit 1

cmake --build build --target install
if errorlevel 1 exit 1
