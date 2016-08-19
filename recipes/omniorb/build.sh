export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++


./configure \
  --prefix=$PREFIX \
  --with-zlib=$PREFIX \

make

make install
