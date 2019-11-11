#!/bin/bash

COMPILER_RT_LIB=$(ls $PREFIX/lib/clang/*/lib/*/libclang_rt.builtins*.a)
COMPILER_RT_LIB_DIR=$(dirname $COMPILER_RT_LIB)
echo "#define CMAKE_BUILD_COMPILER_RT_LIB_DIR \"$COMPILER_RT_LIB_DIR\"" >>  hcc_config/hcc_config.hxx.in

sed -i -r "s/^([ ]*)ld /\1\${LD:-ld} /g" lib/clamp-link.in
sed -i -r "s/^([ ]*)ld /\1\${LD:-ld} /g" lib/hc-kernel-assemble.in

mkdir build
cd build

export CXX=clang++
export CC=clang
export CONDA_BUILD_SYSROOT=$PREFIX/$HOST/sysroot
export CXXFLAGS="$CXXFLAGS -v"

#TODO: Fix the following hack with a patch
ln -s $COMPILER_RT_LIB $PREFIX/lib/

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DHCC_INTEGRATE_ROCDL=no \
  -DHSA_AMDGPU_GPU_TARGET="gfx700;gfx701;gfx702;gfx801;gfx802;gfx803;gfx900;gfx902;gfx904;gfx906;gfx908;gfx1010;gfx1011;gfx1012" \
  ..

cp compiler/bin/* $PREFIX/bin/

make VERBOSE=1 -j${CPU_COUNT}
make install

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/activate/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
