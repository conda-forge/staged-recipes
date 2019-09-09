mkdir build; cd $_

../configure \
    --prefix=$PREFIX \
    --with-cflags=-fPIC \
    --with-cxxflags=-fPIC

make
make test
make install
