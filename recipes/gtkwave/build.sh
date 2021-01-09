export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
./configure --prefix=$PREFIX --with-tcl=$PREFIX/lib --with-tk=$PREFIX/lib --disable-xz
make
