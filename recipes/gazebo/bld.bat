set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\share\pkgconfig;%LIBRARY_PREFIX%\lib\pkgconfig;%PKG_CONFIG_PATH%

mkdir build
cd build
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DBoost_DEBUG=ON ^
    -DTBB_FOUND=1 ^
    -DTBB_INCLUDEDIR=%LIBRARY_PREFIX%\include ^
    -DTBB_LIBRARY_DIR=%LIBRARY_PREFIX%\lib ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
