#!/bin/bash

env

if [[ "$(uname)" == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.9
  export CXXFLAGS="-std=c++11 -stdlib=libc++ $CXXFLAGS"
fi

for pkg in dijitso ufl instant fiat ffc; do
    echo "installing ${pkg}-${PKG_VERSION}"
    git clone -q --depth 1 -b ${pkg}-${PKG_VERSION} https://bitbucket.org/fenics-project/${pkg}.git
    pushd $pkg
    pip install --no-deps .
    popd
done

pkg=dolfin
echo "installing ${pkg}-${PKG_VERSION}"
git clone -q --depth 1 -b ${pkg}-${PKG_VERSION} https://bitbucket.org/fenics-project/${pkg}.git
pushd $pkg
# apply patches
git apply "${RECIPE_DIR}/swig-py3.patch"
if [[ "$(uname)" == "Darwin" ]]; then
    git apply "${RECIPE_DIR}/clang6-explicit-in-copy.patch"
fi

# DOLFIN
mkdir build
cd build

export LIBRARY_PATH=$PREFIX/lib
export INCLUDE_PATH=$PREFIX/include

export BLAS_DIR=$LIBRARY_PATH

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INCLUDE_PATH=$INCLUDE_PATH \
  -DCMAKE_LIBRARY_PATH=$LIBRARY_PATH \
  -DPYTHON_EXECUTABLE=$PYTHON

make VERBOSE=1 -j${CPU_COUNT}
make install
