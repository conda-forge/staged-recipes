
#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBoost_INCLUDE_DIRS=$PREFIX/include \
    -DMSGPACK_BOOST_DIR=$PREFIX/include \
    -DMSGPACK_CXX11=YES \
    -DMSGPACK_BOOST=YES \
    ..

cmake --build .
cmake --build . --target install
