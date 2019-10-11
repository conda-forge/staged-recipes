mkdir build; cd $_

export CFLAGS=-fPIC
export CXXFLAGS=-fpic
export LDFLAGS="-L$PREFIX/lib -lmpi $LDFLAGS"

ls /usr/bin/perl
../configure --prefix=$PREFIX --srcdir=$SRC_DIR

make -j${CPU_COUNT}
make test
make install
