mkdir build
cd build
if errorlevel 1 exit /b 1

cmake %SRC_DIR% ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DBUILD_STATIC_LIBS:BOOL=OFF ^
    -DPTL_USE_TBB:BOOL=OFF ^
    -DPTL_USE_LOCKS:BOOL=OFF ^
    -DPTL_INSTALL_HEADERS:BOOL=ON ^
    -DPTL_INSTALL_CONFIG:BOOL=ON ^
    %CMAKE_ARGS%
if errorlevel 1 exit /b 1

cmake --build .
if errorlevel 1 exit /b 1
