autoreconf -i
./configure --prefix=$PREFIX --enable-mmap	
make
make install
