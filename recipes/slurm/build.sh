./configure --prefix=$PREFIX --sysconfdir=$PREFIX
make -j$CPU_COUNT
make install
mv $PREFIX/sbin/* $PREFIX/bin/
