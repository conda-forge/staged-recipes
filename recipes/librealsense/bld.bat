mkdir build
cd build

cmake -GNinja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DBUILD_SHARED_LIBS=ON ^
    -DENABLE_CCACHE=OFF ^
    -DBUILD_WITH_OPENMP=OFF ^
    -DFORCE_RSUSB_BACKEND=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_UNIT_TESTS=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
