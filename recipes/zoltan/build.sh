mkdir build; cd $_

export CFLAGS=-fPIC
export CXXFLAGS=-fpic
export LDFLAGS="-L$PREFIX/lib -lmpi $LDFLAGS"

../configure --prefix=$PREFIX --srcdir=$PREFIX/../work

make
make test
make install
