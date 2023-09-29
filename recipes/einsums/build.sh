if [ "$(uname)" == "Darwin" ]; then
    ARCH_ARGS=""

    # c-f-provided CMAKE_ARGS handles CMAKE_OSX_DEPLOYMENT_TARGET, CMAKE_OSX_SYSROOT
fi
if [ "$(uname)" == "Linux" ]; then
    ARCH_ARGS=""

    if [[ "$blas_impl" == "mkl" ]]; then
        ARCH_ARGS="-DMKL_LINK=sdl -DMKL_INTERFACE=lp64 ${ARCH_ARGS}"
    elif [[ "$blas_impl" == "openblas" ]]; then
        ARCH_ARGS="-DBLA_VENDOR=OpenBLAS -DBLA_SIZEOF_INTEGER=4 ${ARCH_ARGS}"
    fi
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



#  -D ENABLE_XHOST=OFF
#  -D LAPACK_LIBRARIES="${PREFIX}/lib/liblapack${SHLIB_EXT};${PREFIX}/lib/libblas${SHLIB_EXT}"
#  -D CMAKE_VERBOSE_MAKEFILE=OFF
#  -D EINSUMS_INSTALL_CMAKEDIR=myshare/cmake/Einsums
#  -D CMAKE_DISABLE_FIND_PACKAGE_MKL=ON

cmake --build build --target install

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi

