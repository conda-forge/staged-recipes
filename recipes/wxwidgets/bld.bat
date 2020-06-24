mkdir build_
if errorlevel 1 exit 1
cd build_
if errorlevel 1 exit 1

cmake  ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DwxUSE_ZLIB=sys    ^
    -DwxUSE_EXPAT=sys   ^
    -DwxUSE_LIBJPEG=sys ^
    -DwxUSE_LIBPNG=sys  ^
    -DwxUSE_LIBTIFF=sys ^
    ..
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
