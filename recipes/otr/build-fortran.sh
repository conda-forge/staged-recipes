if [ "$(uname)" == "Darwin" ]; then
    ARCH_ARGS=""

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""

fi

cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_C_FLAGS="${CFLAGS}" \
  -D CMAKE_Fortran_COMPILER=${FC} \
  -D CMAKE_Fortran_FLAGS="${FFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D OpenTrustRegion_INSTALL_CMAKEDIR="lib/cmake/OpenTrustRegion" \
  -D OpenTrustRegion_BUILD_TESTING=ON \
  -D BUILD_SHARED_LIBS=ON \
  -D CMAKE_VERBOSE_MAKEFILE=OFF \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build --target install

# testing library built here is used in py: opentrustregion.testsuite
