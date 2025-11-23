@echo on

if not exist build mkdir build
pushd build

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

cmake --build . --config Release
if %ERRORLEVEL% neq 0 exit 1
cmake --install . --config Release
if %ERRORLEVEL% neq 0 exit 1

popd
