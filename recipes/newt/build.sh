autoconf 

./configure \
  --prefix=$PREFIX \
  --with-python \
  --without-tcl

make
make install
