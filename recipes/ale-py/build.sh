#!/bin/bash
set -ex

mkdir build
cd build

export CMAKE_CXX_COMPILER_AR=llvm-ar

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CPP_LIB=ON \
    -DBUILD_PYTHON_LIB=ON \
    -DSDL_SUPPORT=ON \
    ..

cmake --build .
cmake --install . --prefix $PREFIX

cd ..

# see https://github.com/mgbellemare/Arcade-Learning-Environment/blob/v0.7.5/setup.py#L109-L150
export CIBUILDWHEEL=1
export GITHUB_REF=$PKG_VERSION

python -m pip install . -vv
