mkdir build
cd build

export TBB_ROOT=${PREFIX}

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=Release \
      -DEMBREE_TUTORIALS=OFF \
      -DEMBREE_MAX_ISA="AVX2" \
      -DEMBREE_ISPC_SUPPORT=OFF

make -j ${CPU_COUNT}

# embree lacks unit tests

make install

# remove tutorial models (which embree installed even when EMBREE_TUTORIALS=off)
# this is easier than patching embree's cmake
rm -rf ${PREFIX}/bin/models
