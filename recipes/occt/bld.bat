mkdir build
cd build


cmake ^
    -DCMAKE_PREFIX_PATH=$PREFIX ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ..

make install
