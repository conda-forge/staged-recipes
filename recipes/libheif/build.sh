mkdir build
cd build

cmake -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_SYSTEM_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DWITH_EXAMPLES=OFF \
  ..

ninja

ninja install

