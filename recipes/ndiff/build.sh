mkdir -p $PREFIX/man/man1
./configure --prefix="$PREFIX" --with-gmp
make all
make check
make install
