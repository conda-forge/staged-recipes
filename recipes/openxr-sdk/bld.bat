mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DBUILD_SHARED_LIBS=ON ^
    -DVulkan_FOUND=OFF ^
    -DVULKAN_INCOMPATIBLE=ON ^
    -DDYNAMIC_LOADER=ON ^
    -DFALLBACK_CONFIG_DIRS=%LIBRARY_PREFIX%\etc\xdg ^
    -DFALLBACK_DATA_DIRS=%LIBRARY_PREFIX%\share ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1