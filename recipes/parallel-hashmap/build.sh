mkdir -p build

pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DPHMAP_BUILD_TESTS=OFF \
      -DPHMAP_BUILD_EXAMPLES=OFF \
      ..
      
cmake --build . --config Release
cmake --install .
