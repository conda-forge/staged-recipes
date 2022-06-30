cmake ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -B _build -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_MINIMAL_EXAMPLE=ON
if errorlevel 1 exit 1
cmake --build _build
if errorlevel 1 exit 1
ctest --test-dir _build --output-on-failure
if errorlevel 1 exit 1
cmake --install _build
if errorlevel 1 exit 1

