@echo on

if not exist build mkdir build
cd build

cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DUSE_OPENMP=ON ^
    ..
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

cmake --build . --config Release
if %ERRORLEVEL% neq 0 exit 1
cmake --install . --config Release
if %ERRORLEVEL% neq 0 exit 1

popd
