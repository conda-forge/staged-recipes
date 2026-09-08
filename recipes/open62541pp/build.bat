mkdir build
cd build

cmake ^
    -G "Ninja" ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DBUILD_SHARED_LIBS=ON ^
    -DUAPP_INTERNAL_OPEN62541=OFF ^
    -DUAPP_BUILD_TESTS=OFF ^
    -DUAPP_BUILD_EXAMPLES=OFF ^
    -DUAPP_BUILD_DOCUMENTATION=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
