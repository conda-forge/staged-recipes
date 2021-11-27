locate tkConfig.sh
./configure --exec-prefix=$LIBRARY_PREFIX/ --with-tcl=$LIBRARY_PREFIX/lib/ --with-tk=$LIBRARY_PREFIX/lib/  --enable-threads
make
make install
