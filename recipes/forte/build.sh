ARCH_ARGS=""

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_C_FLAGS="${CFLAGS}" \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D Python_EXECUTABLE=${PYTHON} \
  -D CMAKE_VERBOSE_MAKEFILE=OFF \
  -D CMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

# NOTE: CMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF is for reducing link time (quarters build time) for testing. remove line for production builds.

cmake --build build --target install

