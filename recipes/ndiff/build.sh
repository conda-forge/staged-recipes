mkdir -p $PREFIX/man/man1
./configure --prefix="$PREFIX" --with-gmp
make all -j ${CPU_COUNT}
make check
make install
