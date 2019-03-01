mkdir build
cd build

REM Configure step
cmake .. ^
    -GNinja ^
    -DBUILD_SHARED_LIBS=ON ^
    -DYAML_CPP_BUILD_TESTS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

REM Build step
ninja install
if errorlevel 1 exit 1
