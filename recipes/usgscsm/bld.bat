mkdir build
cd build
cmake -G "NMake Makefiles" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^ 
    -D CMAKE_PREFIX_PATH=%PREFIX% ^
    -D BUILD_CSM=OFF  ^
    -D BUILD_TESTS=OFF
     %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
