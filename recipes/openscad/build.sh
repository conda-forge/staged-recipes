mkdir -p build
cd build

cmake -G "Ninja" \
      -D CMAKE_INSTALL_PREFIX:FILEPATH="$PREFIX" \
      ..

ninja install