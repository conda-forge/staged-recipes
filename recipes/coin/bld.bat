mkdir build
cd build

cmake .. -G "Ninja" ^
    -DCMAKE_PREFIX_PATH:FILEPATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE="Release"

if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

rem we have to find a way to do this with windows
rem mkdir build-cfg -p
rem cd build-cfg
rem ../configure --prefix=$PREFIX --without-framework --enable-3ds-import --disable-dependency-tracking
rem make coin-default.cfg
rem cp coin-default.cfg $PREFIX/share/