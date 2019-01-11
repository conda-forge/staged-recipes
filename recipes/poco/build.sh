mkdir build-conda
pushd build-conda

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DENABLE_DATA_MYSQL=OFF \
    -DENABLE_DATA_ODBC=OFF \
    -GNinja ..

ninja
ninja install

popd
