mkdir -p build

pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DDEBUG=OFF \
      -DOPENMP=set \
      -DBUILD_SHARED_LIBS=OFF \
      ..

cmake --build . --config Release
cmake --install .
