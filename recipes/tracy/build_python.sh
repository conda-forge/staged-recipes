#!/bin/sh

rm -rf build
# Python module from previous build can be copied in the source directory.
# We must remove them to avoid binary conflict.
rm -rf python/tracy_client/*.so* python/tracy_client/__pycache__

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
# this will also install headers again
# but without the Tracy(Targets*|Config).cmake files
$PYTHON -m pip install . --no-deps --ignore-installed
