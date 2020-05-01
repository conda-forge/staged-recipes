cd src
cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release
make all -j$CPU_COUNT
make install
