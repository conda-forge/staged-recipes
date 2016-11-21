export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

ZLIB_ROOT=$PREFIX
./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
