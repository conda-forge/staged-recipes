mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DFMI4CPP_BUILD_TESTS:BOOL=ON  ^
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
