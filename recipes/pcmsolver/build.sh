#!/usr/bin/env bash

set -ex

${BUILD_PREFIX}/bin/cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G "Ninja" \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_C_FLAGS="${CFLAGS}" \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D CMAKE_Fortran_COMPILER=${FC} \
  -D CMAKE_Fortran_FLAGS="${FFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D PYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
  -D Python_EXECUTABLE=${PYTHON} \
  -D EIGEN3_ROOT=${PREFIX} \
  -D ENABLE_OPENMP=OFF \
  -D ENABLE_GENERIC=OFF \
  -D ENABLE_TESTS=ON \
  -D ENABLE_TIMER=OFF \
  -D ENABLE_LOGGER=OFF \
  -D BUILD_STANDALONE=ON \
  -D ENABLE_CXX11_SUPPORT=ON

cmake --build build --target install -j${CPU_COUNT}

# Building both static & shared (instead of SHARED_LIBRARY_ONLY) since the tests
#   only build with static lib. Don't want to distribute static, though, so
#   removing all the static lib stuff immediately after install.
rm ${PREFIX}/share/cmake/PCMSolver/PCMSolverTargets-static-release.cmake
rm ${PREFIX}/share/cmake/PCMSolver/PCMSolverTargets-static.cmake
rm ${PREFIX}/lib/libpcm.a

cd build
ctest --rerun-failed --output-on-failure -j${CPU_COUNT}

