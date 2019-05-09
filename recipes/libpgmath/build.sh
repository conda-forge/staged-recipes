cd runtime/libpgmath

mkdir build
cd build

export CC=$PREFIX/bin/clang
export CXX=$PREFIX/bin/clang++

PIP_NO_INDEX= pip install lit

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  ..

make -j${CPU_COUNT}
make install
make check-libpgmath
