cmake                                        ^
    -G "Ninja"                               ^
    -D SOCI_CXX11=ON                         ^
    -D WITH_BOOST=OFF                        ^
    -D CMAKE_BUILD_TYPE=Release              ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DSOCI_LIBDIR=lib                        ^
    -DSOCI_STATIC=OFF                        ^
    %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
