#! /bin/bash

mkdir -p build && cd build

cmake -GNinja \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_PYSCAFFOLDER=OFF \
  -DVERSION=$SCAFFOLDER_VERSION \
  ../

cmake --build . --config Release
cmake --install .