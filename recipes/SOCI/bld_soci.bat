cmake                                        ^
    -G "Ninja"                               ^
    -DSOCI_CXX11=ON                         ^
    -DWITH_BOOST=OFF                        ^
    -DCMAKE_BUILD_TYPE=Release              ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DSOCI_LIBDIR=lib                        ^
    -DSOCI_STATIC=OFF                        ^
    -DCMAKE_CXX_FLAGS=-DNOMINMAX             ^
    %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
