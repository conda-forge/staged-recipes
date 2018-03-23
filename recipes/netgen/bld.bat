mkdir build
cd build

REM TODO: can not find tkint.h -> disabling GUI for WIN 

cmake .. -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DINSTALL_DIR_LAYOUT="Unix" ^
    -DCMAKE_PREFIX_PATH:FILEPATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -DNG_INSTALL_DIR_INCLUDE:FILEPATHE="%LIBRARY_PREFIX%/include/netgen" ^
    -DOCC_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%/include/opencascade" ^
    -DOCC_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%/lib" ^
    -DUSE_OCC=ON ^
    -DUSE_PYTHON=ON ^
    -DUSE_GUI=OFF ^
    -DUSE_SUPERBUILD=OFF

if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
