export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

./configure \
  --prefix=$PREFIX

make

make install
