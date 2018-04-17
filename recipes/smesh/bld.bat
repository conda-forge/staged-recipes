mkdir build
cd build

cmake -G "Ninja" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
    -D PTHREAD_INCLUDE_DIRS:FILE_PATH="%LIBRARY_PREFIX%/include" ^
    -D PTHREAD_LIB_DIRS:FILE_PATH="%LIBRARY_PREFIX%/lib" ^
    ..

if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
