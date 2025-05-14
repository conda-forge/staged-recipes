mkdir build && cd build

cmake -G "Ninja" ^
    -D CMAKE_BUILD_TYPE=Release% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_VERBOSE_MAKEFILE=%CMAKE_VERBOSE_MAKEFILE% ^
    -D CMAKE_LIBRARY_PATH:FILEPATH="=%LIBRARY_LIB%" ^
    -D CMAKE_INCLUDE_PATH:FILEPATH="%LIBRARY_INC%" ^
    %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

ctest -V --output-on-failure
if errorlevel 1 exit 1
