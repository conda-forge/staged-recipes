cd runtime/libpgmath

mkdir build
cd build

if [[ $target_platform == "osx-64" ]]; then
  export CC=$PREFIX/bin/clang
  export CXX=$PREFIX/bin/clang++
  export LIBRARY_PREFIX=$PREFIX
elif [[ $target_platform == "win-64" ]]; then
  export CC=clang-cl.exe
  export CXX=clang-cl.exe
  export LIBRARY_PREFIX=$PREFIX/Library
  export CMAKE_GENERATOR="MSYS Makefiles"
else
  export CC=$BUILD_PREFIX/bin/clang
  export CXX=$BUILD_PREFIX/bin/clang++
  export LIBRARY_PREFIX=$PREFIX
fi

PIP_NO_INDEX= pip install lit

cmake \
  -G "${CMAKE_GENERATOR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$LIBRARY_PREFIX \
  -DCMAKE_PREFIX_PATH=$LIBRARY_PREFIX \
  ..

make -j${CPU_COUNT}
make install
make check-libpgmath
