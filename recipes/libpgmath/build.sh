cd runtime/libpgmath

mkdir build
cd build

if [[ $target_platform == "osx-64" ]]; then
  export CC=$PREFIX/bin/clang
  export CXX=$PREFIX/bin/clang++
  export LIBRARY_PREFIX=$PREFIX
elif [[ $target_platform == "win-64" ]]; then
  export CC=$BUILD_PREFIX/Library/bin/clang-cl.exe
  export CXX=$BUILD_PREFIX/Library/bin/clang-cl.exe
  export LIBRARY_PREFIX=$PREFIX/Library
  export EXTRA_CMAKE_ARGS="-G \"MSYS Makefiles\""
else
  export CC=$BUILD_PREFIX/bin/clang
  export CXX=$BUILD_PREFIX/bin/clang++
  export LIBRARY_PREFIX=$PREFIX
fi

PIP_NO_INDEX= pip install lit

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$LIBRARY_PREFIX \
  -DCMAKE_PREFIX_PATH=$LIBRARY_PREFIX \
  $EXTRA_CMAKE_ARGS \
  ..

make -j${CPU_COUNT}
make install
make check-libpgmath
