if [ "$(uname)" == "Darwin" ]; then
    ARCH_ARGS=""
#    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
    _TESTS=OFF
#error: no member named 'assoc_legendre' in namespace 'std'

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""
    _TESTS=ON

fi

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D BUILD_SHARED_LIBS=ON \
  -D INTEGRATORXX_ENABLE_TESTS=${_TESTS} \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

#  -D OpenOrbitalOptimizer_INSTALL_CMAKEDIR="share/cmake/OpenOrbitalOptimizer"

cmake --build build --target install -j${CPU_COUNT}

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi

