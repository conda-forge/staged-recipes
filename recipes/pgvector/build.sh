#!/bin/bash
set -ex

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
export CFLAGS="-march=native"
fi

export CMAKE_BUILD_TYPE=Release
export BUILD_SHARED_LIBS=ON
export CMAKE_BUILD_WITH_INSTALL_RPATH=ON

mkdir build
pushd build

cmake -GNinja ${CMAKE_ARGS} \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    ..

cmake --build . --verbose --config Release -- -v -j ${CPU_COUNT}
cmake --install . --verbose --config Release

popd

python $RECIPE_DIR/test_pgvector.py

