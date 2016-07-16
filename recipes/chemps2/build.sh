mkdir build
cd build

if [ "$(uname)" == "Darwin" ]; then

    HDF5_INTERJECT="-L${PREFIX}/lib;-lhdf5;-lhdf5_hl;-lhdf5;-lpthread;-lz;-ldl;-lm"

    # configure
    cmake \
        -DCMAKE_CXX_COMPILER="${PREFIX}/bin/g++" \
        -DCMAKE_C_COMPILER="${PREFIX}/bin/gcc" \
        -DEXTRA_C_FLAGS="''" \
        -DEXTRA_CXX_FLAGS="''" \
        -DSHARED_ONLY=ON \
        -DENABLE_GENERIC=OFF \
        -DMKL=OFF \
        -DBUILD_DOXYGEN=OFF \
        -DBUILD_SPHINX=OFF \
        -DENABLE_TESTS=OFF \
        -DHDF5_LIBRARIES="${HDF5_INTERJECT}" \
        -DHDF5_INCLUDE_DIRS="${PREFIX}/include" \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_INSTALL_LIBDIR=lib \
        ${SRC_DIR}

fi

# build
make -j${CPU_COUNT}

# install
make install

# test
# tests just segfault

