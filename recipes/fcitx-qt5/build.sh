mkdir -p build
cd build

cmake \
      -D ENABLE_LIBRARY:BOOL=OFF \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D CMAKE_PREFIX_PATH:FILEPATH=$PREFIX \
      ..

make install