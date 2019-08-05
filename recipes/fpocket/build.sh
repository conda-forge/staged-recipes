ln -s ${CC} ${PREFIX}/bin/gcc
make
make install BINDIR=$PREFIX/bin MANDIR=$PREFIX/man/man8
rm ${PREFIX}/bin/gcc
