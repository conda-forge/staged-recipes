
# cget install -DBUILD_SHARED_LIBS=1 -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC" --prefix "$PREFIX" --release "jonathonl/shrinkwrap@v1.0.0-beta"

cmake \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  .

make -j${CPU_COUNT} install
