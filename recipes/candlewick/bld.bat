setlocal EnableDelayedExpansion

:: Configure using the CMakeFiles!
cmake -S . -B build -G Ninja ^
        -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
        -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
        -DCMAKE_BUILD_TYPE:STRING=Release ^
        -DBUILD_PINOCCHIO_VISUALIZER:BOOL=ON ^
        -DBUILD_PYTHON_BINDINGS:BOOL=ON ^
        -DBUILD_EXAMPLES:BOOL=OFF ^
        -DBUILD_TESTING:BOOL=OFF

if errorlevel 1 exit 1

:: Build!
cmake --build build -j${CPU_COUNT}
if errorlevel 1 exit 1

:: Install!
cmake --install build --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1