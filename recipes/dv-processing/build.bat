mkdir build
cd build

REM Configure step
cmake .. ^
    -G "Ninja" ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

REM Build step
cmake --build . --config Release
if errorlevel 1 exit 1
cmake --build . --config Release --target install
if errorlevel 1 exit 1