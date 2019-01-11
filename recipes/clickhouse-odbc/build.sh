mkdir build
pushd build

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DOPENSSL_ROOT_DIR=$PREFIX \
    -DOPENSSL_USE_SHARED_LIBS=ON \
    -DODBC_INCLUDE_DIRECTORIES=$PREFIX/include \
    -DUNBUNDLED=ON \
    -GNinja ..

ninja
ninja install

popd
