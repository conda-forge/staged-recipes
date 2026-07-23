#!/usr/bin/env bash
set -euxo pipefail

# Belt-and-braces against archive extraction leaving the top-level pFUnit-v<ver>/
# dir in place: if CMakeLists.txt is not at the source root, descend into it.
if [ ! -f CMakeLists.txt ]; then
  d="$(find . -maxdepth 1 -type d -name 'pFUnit-*' | head -1)"
  [ -n "$d" ] && cd "$d"
fi

# Options mirror mo-spack-packages' pfunit recipe:
#  - static libraries (BUILD_SHARED_LIBS=OFF), as the whole Goddard group is built;
#  - MPI enabled (SKIP_MPI=NO): pFUnit's CMake does find_package(MPI COMPONENTS
#    Fortran), which picks up conda's MPI from $PREFIX -- no need to override the
#    Fortran compiler to mpif90;
#  - OpenMP/hamcrest/ESMF and pFUnit's own tests skipped;
#  - MAX_ASSERT_RANK=5, the upstream/Spack default.
# find_package(GFTL/GFTL_SHARED/FARGPARSE) and find_package(Python) resolve from
# the host dependencies via CMAKE_PREFIX_PATH=$PREFIX.
#
# CMAKE_ARGS is a flag STRING from the compiler activation and must word-split.
# shellcheck disable=SC2086
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_SHARED_LIBS=OFF \
  -DSKIP_MPI=NO \
  -DSKIP_OPENMP=YES \
  -DSKIP_FHAMCREST=YES \
  -DSKIP_ESMF=YES \
  -DENABLE_TESTS=NO \
  -DENABLE_MPI_F08=NO \
  -DMAX_ASSERT_RANK=5

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
