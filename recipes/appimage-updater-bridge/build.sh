mkdir -p build
cd build

cmake -G "Ninja" \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:FILEPATH=$PREFIX/plugins \
      -D BUILD_AS_PLUGIN:BOOL=ON \
      ..

ninja install