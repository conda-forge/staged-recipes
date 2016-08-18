export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++


./configure \
  --prefix=$PREFIX \

make

make install
