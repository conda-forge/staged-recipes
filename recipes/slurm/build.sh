./configure --prefix=$PREFIX --sysconfdir=$PREFIX
make -j$CPU_COUNT
make install
make check
mv $PREFIX/sbin/* $PREFIX/bin/
