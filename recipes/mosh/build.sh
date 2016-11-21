# See https://github.com/conda-forge/toolchain-feedstock/pull/11
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include `pkg-config --cflags zlib`"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib `pkg-config --libs zlib`"

./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
