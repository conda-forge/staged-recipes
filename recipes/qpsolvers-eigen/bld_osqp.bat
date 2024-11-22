rmdir /S /Q build_osqp
mkdir build_osqp
cd build_osqp

cmake %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "Ninja" ^
    -DBUILD_TESTING:BOOL=ON ^
    %SRC_DIR%\plugins\osqp
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
