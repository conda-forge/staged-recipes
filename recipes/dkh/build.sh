
${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
    -S ${SRC_DIR} \
    -B build \
    -G "Ninja" \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_C_COMPILER=${CC} \
    -D CMAKE_C_FLAGS="${CFLAGS}" \
    -D CMAKE_Fortran_COMPILER=${FC} \
    -D CMAKE_Fortran_FLAGS="${FFLAGS}" \
    -D CMAKE_INSTALL_LIBDIR=lib \
    -D BUILD_SHARED_LIBS=ON \
    -D LAPACK_LIBRARIES="${PREFIX}/lib/libblas${SHLIB_EXT}" \
    -D ENABLE_OPENMP=OFF \
    -D ENABLE_XHOST=OFF

cmake --build build --target install -j${CPU_COUNT}

# no independent tests
