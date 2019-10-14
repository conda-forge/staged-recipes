mkdir build; cd $_

export LDFLAGS="-L$PREFIX/lib -lmpi $LDFLAGS"

../configure --prefix=$PREFIX --srcdir=$SRC_DIR

make -j${CPU_COUNT}
make test
make install
