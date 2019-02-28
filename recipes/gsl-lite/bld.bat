mkdir build
cd build

cmake -LAH ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    .. || goto :eof

cmake --build . --config Release --target install
