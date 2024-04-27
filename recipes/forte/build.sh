if [[ "${target_platform}" == osx-* ]]; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi

cmake ${CMAKE_ARGS} \
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
  -D ENABLE_OPENMP=ON \
  -D ENABLE_MPI=OFF \
  -D ENABLE_CheMPS2=OFF \
  -D ENABLE_ForteTests=OFF \
  -D CMAKE_VERBOSE_MAKEFILE=OFF \
  -D CMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

# NOTE: CMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF is for reducing link time (quarters build time) for testing. remove line for production builds.

cmake --build build --target install

