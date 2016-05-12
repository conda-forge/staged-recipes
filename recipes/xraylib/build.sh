libtoolize
autoreconf -i
./configure --enable-python --disable-perl --disable-java \
	    --disable-fortran2003 --disable-lua --prefix=$PREFIX
make
make install
