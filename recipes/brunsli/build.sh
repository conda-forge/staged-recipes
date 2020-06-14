mkdir build
cd build


cmake -LAH                            \
    -DCMAKE_BUILD_TYPE=Release        \
    -DCMAKE_INSTALL_PREFIX=$PREFIX    \
    ..

make -j${CPU_COUNT}
make install
