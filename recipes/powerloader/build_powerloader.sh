rm -rf build
mkdir build
cd build

cmake .. ${CMAKE_ARGS}              \
    -GNinja                         \
    -DCMAKE_INSTALL_PREFIX=$PREFIX  \
    -DCMAKE_PREFIX_PATH=$PREFIX     \
    -DENABLE_TESTS=OFF              \
    -DENABLE_PYTHON=OFF

ninja

ninja install

