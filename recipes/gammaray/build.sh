
mkdir build
pushd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib
make
make install

popd
rm -rf build
