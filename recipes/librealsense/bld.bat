mkdir build
cd build

cp %SRC_DIR%\src\win7\drivers\IntelRealSense_D400_series_win7.inf %SRC_DIR%

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
    -DLIBUSB_LIB=%LIBRARY_LIB%\libusb-1.0.lib ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
