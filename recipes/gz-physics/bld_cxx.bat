mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DBUILD_TESTING=ON ^
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
    -DCMAKE_CXX_FLAGS="/permissive- /D_USE_MATH_DEFINES" ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test
ctest --output-on-failure -C Release -E "check_|INTEGRATION_ExamplesBuild_TEST|UNIT_Collisions_TEST|UNIT_EntityManagement_TEST"
if errorlevel 1 exit 1
