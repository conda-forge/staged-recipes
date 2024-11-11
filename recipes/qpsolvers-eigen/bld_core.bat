rmdir /S /Q build
mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "Ninja" ^
    -DBUILD_TESTING:BOOL=OFF ^
    -DQPSOLVERSEIGEN_USES_SYSTEM_SHAREDLIBPP:BOOL=ON ^
    -DQPSOLVERSEIGEN_USES_SYSTEM_YCM:BOOL=ON ^
    -DQPSOLVERSEIGEN_ENABLE_OSQP:BOOL=OFF ^
    -DQPSOLVERSEIGEN_ENABLE_PROXQP:BOOL=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
