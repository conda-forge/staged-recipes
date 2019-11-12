#!/bin/bash

export CC=$PREFIX/bin/clang
export CXX=$PREFIX/bin/clang++
export CONDA_BUILD_SYSROOT=$PREFIX/$HOST/sysroot

cp bin/hipconfig $PREFIX/bin/

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DHIP_COMPILER=clang \
  -DHSA_PATH=$PREFIX \
  -DHIP_PATH=$PREFIX \
  -DHIP_CLANG_PATH=$PREFIX/bin \
  -DDEVICE_LIB_PATH=$PREFIX/lib \
  -DBUILD_HIPIFY_CLANG=yes \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/activate/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
