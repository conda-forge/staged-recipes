
mkdir build && cd build
cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DINSTALL_INCLUDEDIR=include/qt6 ^
    -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
