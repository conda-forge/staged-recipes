
#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBoost_INCLUDE_DIRS=$PREFIX \
    -DMSGPACK_BOOST_DIR=$PREFIX \
    -DMSGPACK_BOOST=YES \
    ..

make

make install
