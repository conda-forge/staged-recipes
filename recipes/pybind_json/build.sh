mkdir -p build
pushd build

cmake -DCMAKE_BUILD_TYPE=Release     \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DDISABLE_ARCH_NATIVE=ON       \
      -DCMAKE_INSTALL_LIBDIR=lib     \
      -DPYTHON_EXECUTABLE=$PYTHON    \
      $SRC_DIR

make -j${CPU_COUNT} install
