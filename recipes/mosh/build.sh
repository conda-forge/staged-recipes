# See https://github.com/conda-forge/toolchain-feedstock/pull/11
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure --prefix="${PREFIX}" \
            --with-ncurses \
            --with-curses=$PREFIX \
            --with-crypto-library=openssl
make -j"${CPU_COUNT}"
make install
