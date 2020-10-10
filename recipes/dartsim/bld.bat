mkdir build && cd build

cmake -G "NMake Makefiles"^
    -DCMAKE_BUILD_TYPE=Release^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%^
    -DDART_MSVC_DEFAULT_OPTIONS=ON^
    %SRC_DIR%

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
