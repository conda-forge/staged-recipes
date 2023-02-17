
${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D BUILD_SHARED_LIBS=ON \
  -D Eigen3_ROOT=${PREFIX} \
  -D ENABLE_XHOST=OFF \
  -D LIBINT2_REQUIRE_CXX_API=ON \
  -D LIBINT2_REQUIRE_CXX_API_COMPILED=OFF \
  -D LIBINT2_ENABLE_FORTRAN=OFF \
  -D LIBINT2_ENABLE_PYTHON=OFF \
  -D BUILD_TESTING=ON \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

# use `--target check install` above to run ctest tests within build phase. adds about 10m.

cmake --build build --target install -j${CPU_COUNT}

# generation of the source tarball included the following settings (plus ints classes, AM, deriv)
#  -D LIBINT2_SHGAUSS_ORDERING=standard
#  -D LIBINT2_CARTGAUSS_ORDERING=standard
#  -D LIBINT2_SHELL_SET=standard
#  -D ERI3_PURE_SH=OFF
#  -D ERI2_PURE_SH=OFF
