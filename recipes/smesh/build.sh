mkdir -p build
cd build

cmake -G "Ninja" \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_PREFIX_PATH=$PREFIX \
      -D CMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
      -D CMAKE_CXX_FLAGS="-std=c++11" \
      -D ENABLE_MED=OFF \
      ..

ninja install