mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "Ninja" ^
    -DBUILD_TESTING:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Test
ctest --output-on-failure  -C Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
