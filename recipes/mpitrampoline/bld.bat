cmake -B build -G Ninja ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%
if errorlevel 1 exit /b 1
cmake --build build
if errorlevel 1 exit /b 1
cmake --install build
if errorlevel 1 exit /b 1
