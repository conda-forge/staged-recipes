#!/bin/sh

rm -rf build

mkdir build && cd build

cmake ${CMAKE_ARGS} .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -GNinja \
    -DTRACY_CLIENT_PYTHON=ON \
    -DPython_EXECUTABLE="$PYTHON"

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --target install

cd ../python
# # this will also install headers again
# # but without the Tracy(Targets*|Config).cmake files
pip install . --target $PREFIX
