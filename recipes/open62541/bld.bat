mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DBUILD_SHARED_LIBS=ON ^
    -DUA_ENABLE_ENCRYPTION_OPENSSL=ON ^
    -DUA_ENABLE_HISTORIZING=ON ^
    -DUA_NAMESPACE_ZERO=REDUCED ^
    -DOPEN62541_VERSION=v%PKG_VERSION% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1