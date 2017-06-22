mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    ..

make -j${CPU_COUNT}
make install

mkdir -p $PREFIX/lib/clang/$PKG_VERSION/include
# Standalone libomp build doesn't put omp.h in clang's default search path
cp $PREFIX/include/omp.h $PREFIX/lib/clang/$PKG_VERSION/include
