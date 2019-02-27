mkdir build
cd build

CMAKE_CONFIG="Release"

cmake -LAH \
  -DCMAKE_BUILD_TYPE=$CMAKE_CONFIG \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  ..

cmake --build . --config $CMAKE_CONFIG --target install

