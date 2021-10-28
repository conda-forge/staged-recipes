mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DPXR_HEADLESS_TEST_MODE:BOOL=ON ^
    -DPXR_BUILD_IMAGING:BOOL=OFF ^
    -DPXR_BUILD_USD_IMAGING=OFF ^
    -DPXR_ENABLE_PYTHON_SUPPORT=OFF ^
    -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=ON ^
    -DPXR_USE_PYTHON_3:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1
