mkdir build
cd build

cmake .. -G "Ninja" ^
    -DCMAKE_PREFIX_PATH:FILEPATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -DTK_LIBRARY_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
    -DTCL_LIBRARY_PATH_PARENT="%LIBRARY_PREFIX%" ^
    -DUSE_TBB=ON ^
    -DUSE_FREEIMAGE=ON

if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
