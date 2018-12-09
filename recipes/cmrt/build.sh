# https://01.org/linuxgraphics/documentation/build-guide-0

export CFLAGS="${CFLAGS} -lrt"
export CXXFLAGS="${CXXFLAGS} -lrt"
./autogen.sh --prefix=$PREFIX
make -j$(nproc) install
