mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make test ARGS="-V"
make install
