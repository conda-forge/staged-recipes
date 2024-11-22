mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -G "Ninja" ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_F2C:BOOL=OFF ^
    -DBUILD_WITH_DEFAULT_MSVC_RUNTIME_LIBRARY:BOOL=ON ^
    -DUSE_LTO:BOOL=OFF ^
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
