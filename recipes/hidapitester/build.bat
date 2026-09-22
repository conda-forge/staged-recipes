cmake -S . -B build -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DHIDAPITESTER_VERSION=v%PKG_VERSION%
if errorlevel 1 exit 1

cmake --build build --config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1
