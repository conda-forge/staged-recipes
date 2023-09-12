

cmake -S . -B build \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR="$PREFIX/lib" \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DMZ_BUILD_TESTS=ON \
  -DMZ_BUILD_UNIT_TESTS=ON \
  -DMZ_LIBCOMP=OFF \
  -DMZ_OPENSSL=ON \
  -DMZ_ZLIB=ON \
  -DCMAKE_INSTALL_INCLUDEDIR=include/minizip \
  -DMZ_FORCE_FETCH_LIBS=OFF

cmake --build build

ctest --output-on-failure -C Release

cmake --install build
