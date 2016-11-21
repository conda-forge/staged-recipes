export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
