if [ "$(uname)" == "Darwin" ]; then
    # avoid "error: use of undeclared identifier 'aligned_alloc'; did you mean 'omp_aligned_alloc'?"
    ARCH_ARGS="-DEINSUMS_H5CPP_USE_OMP_ALIGNED_ALLOC=ON"
    # avoid "error: 'bad_variant_access' is unavailable: introduced in macOS 10.13"
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""

fi

# ensure lp64 interface for now
if [[ "$blas_impl" == "mkl" ]]; then
    ARCH_ARGS="-DMKL_LINK=sdl -DMKL_INTERFACE=lp64 ${ARCH_ARGS}"
elif [[ "$blas_impl" == "openblas" ]]; then
    ARCH_ARGS="-DBLA_VENDOR=OpenBLAS -DBLA_SIZEOF_INTEGER=4 ${ARCH_ARGS}"
fi

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
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D EINSUMS_STATIC_BUILD=OFF \
  -D EINSUMS_ENABLE_TESTING=ON \
  -D EINSUMS_USE_HPTT=ON \
  -D FETCHCONTENT_QUIET=OFF \
  -D CMAKE_REQUIRE_FIND_PACKAGE_Catch2=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_fmt=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_range-v3=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_netlib=ON \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build --target install

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi

