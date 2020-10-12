mkdir build
cd build

cmake ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..

cmake --build . --config Release --target install
