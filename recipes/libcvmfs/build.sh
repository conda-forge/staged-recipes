#!/bin/bash
set -euxo pipefail

# The top-level CMakeLists.txt overwrites CMAKE_PREFIX_PATH with the location
# of the vendored externals, so the conda prefix has to be provided through
# the environment for the remaining dependencies to be found.
export CMAKE_PREFIX_PATH="${PREFIX}"

# The sha3 external detects the CPU architecture by compiling and running a
# test program, which cannot work when cross-compiling. Pre-seed the result
# (64opt is the x86_64 optimised Keccak implementation, 64compact the
# generic 64-bit one).
case "${target_platform}" in
  linux-64 | osx-64)
    echo 64opt > "${SRC_DIR}/externals/sha3/src/arch"
    ;;
  *)
    echo 64compact > "${SRC_DIR}/externals/sha3/src/arch"
    ;;
esac

# Pre-create the (legacy, suffix-free) externals directories so their
# location is predictable, and point the SHA3 find module at the result
# directly: the toolchain's CMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY on Linux
# stops find_library from searching paths outside the conda prefixes. The
# sha3 external is scheduled for replacement upstream (cvmfs/cvmfs#3576),
# after which this can go.
mkdir -p "${SRC_DIR}/externals_build" "${SRC_DIR}/externals_install"

# Only sha3 (not packaged on conda-forge) is built from the vendored
# externals; everything else comes from conda-forge, including OpenSSL for
# libcvmfs_crypto (see cvmfs/cvmfs#4339).
cmake ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_CVMFS=OFF \
  -DBUILD_SERVER=OFF \
  -DBUILD_RECEIVER=OFF \
  -DBUILD_GEOAPI=OFF \
  -DBUILD_LIBCVMFS=ON \
  -DBUILD_LIBCVMFS_CACHE=OFF \
  -DINSTALL_MOUNT_SCRIPTS=OFF \
  -DINSTALL_PUBLIC_KEYS=OFF \
  -DINSTALL_BASH_COMPLETION=OFF \
  -DHELP2MAN=HELP2MAN-NOTFOUND \
  -DSHA3_INCLUDE_DIRS="${SRC_DIR}/externals_install/include" \
  -DSHA3_LIBRARIES="${SRC_DIR}/externals_install/lib/libsha3.a" \
  -DBUILTIN_EXTERNALS=ON \
  "-DBUILTIN_EXTERNALS_LIST=sha3" \
  "-DBUILTIN_EXTERNALS_EXCLUDE=json;libcrypto" \
  -S "${SRC_DIR}" \
  -B build

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# Collect the license files of the statically linked vendored libraries
mkdir -p "${SRC_DIR}/vendored-licenses"
cp "${SRC_DIR}/externals/sha3/src/LICENSE" "${SRC_DIR}/vendored-licenses/LICENSE.sha3"
