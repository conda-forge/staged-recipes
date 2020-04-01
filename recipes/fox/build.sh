./configure
make
make check 
make DESTDIR=${PREFIX} install
