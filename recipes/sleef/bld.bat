mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..

cmake --build . --target install
