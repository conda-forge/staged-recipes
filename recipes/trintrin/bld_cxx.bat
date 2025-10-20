mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -G "Ninja" ^
    -DTRINTRIN_COMPILE_PYTHON_BINDINGS:BOOL=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
