cd runtime/libpgmath

mkdir build
cd build

if [[ $target_platform == "osx-64" ]]; then
  export CC=$PREFIX/bin/clang
  export CXX=$PREFIX/bin/clang++
else
  export CC=$BUILD_PREFIX/bin/clang
  export CXX=$BUILD_PREFIX/bin/clang++
fi

PIP_NO_INDEX= pip install lit

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  ..

make -j${CPU_COUNT}
make install
make check-libpgmath
