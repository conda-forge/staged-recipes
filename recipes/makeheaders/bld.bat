mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    %SRC_DIR%

if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1