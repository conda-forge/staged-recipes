#!bin/sh

rm -rf build

mkdir build && cd build

cmake ${CMAKE_ARGS} .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -GNinja \
    -DBUILD_WITH_CHOLMOD_SUPPORT=ON \
    -DPython_EXECUTABLE=$PYTHON \
    -DBUILD_TESTING=OFF

# build
cmake --build . --parallel ${CPU_COUNT}
# install
cmake --build . --target install