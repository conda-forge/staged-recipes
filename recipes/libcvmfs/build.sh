#!/bin/bash
set -euxo pipefail

# The top-level CMakeLists.txt overwrites CMAKE_PREFIX_PATH with the location
# of the vendored externals, so the conda prefix has to be provided through
# the environment for the remaining dependencies to be found.
export CMAKE_PREFIX_PATH="${PREFIX}"

# cvmfs >=2.14 forces CMAKE_BUILD_TYPE to empty, dropping the -DNDEBUG that
# Release builds would add. Without it the protobuf-generated code keeps its
# ABSL_DCHECK paths, which would additionally require linking abseil.
export CFLAGS="${CFLAGS} -DNDEBUG"
export CXXFLAGS="${CXXFLAGS} -DNDEBUG"

# Build libcvmfs_crypto against the environment's OpenSSL instead of the
# vendored static LibreSSL, following Gentoo's unbundling approach. The
# LIBRESSL_VERSION_NUMBER define only defeats the include guard in
# cvmfs/crypto/openssl_version.h; API selection uses OPENSSL_VERSION_NUMBER.
export CFLAGS="${CFLAGS} -DLIBRESSL_VERSION_NUMBER=1"
export CXXFLAGS="${CXXFLAGS} -DLIBRESSL_VERSION_NUMBER=1"

# The sha3 external detects the CPU architecture by compiling a test program
# with the system `cc`, which does not exist in the conda-forge build
# containers. Pre-seed the detection result instead (64opt is the x86_64
# optimised Keccak implementation, 64compact the generic 64-bit one).
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
# stops find_library from searching paths outside the conda prefixes.
mkdir -p "${SRC_DIR}/externals_build" "${SRC_DIR}/externals_install"

# libcvmfs_util needs libcap on Linux (util/capabilities.cc), but upstream's
# find_package(LibCAP) only runs when the FUSE client or server is built, so
# provide the result directly.
EXTRA_CMAKE_ARGS=""
if [[ "${target_platform}" == linux-* ]]; then
  EXTRA_CMAKE_ARGS="-DCAP_LIBRARIES=${PREFIX}/lib/libcap${SHLIB_EXT}"
fi

mkdir -p build
cd build

# Only the third-party libraries that are not packaged on conda-forge (or, in
# the case of libcrypto, that cvmfs requires as a private static LibreSSL) are
# built from the vendored externals; everything else comes from conda-forge.
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
  -DLibcrypto_INCLUDE_DIRS="${PREFIX}/include" \
  -DLibcrypto_LIBRARIES="${PREFIX}/lib/libcrypto${SHLIB_EXT}" \
  -DSHA3_INCLUDE_DIRS="${SRC_DIR}/externals_install/include" \
  -DSHA3_LIBRARIES="${SRC_DIR}/externals_install/lib/libsha3.a" \
  -DBUILTIN_EXTERNALS=ON \
  "-DBUILTIN_EXTERNALS_LIST=sha3" \
  "-DBUILTIN_EXTERNALS_EXCLUDE=json;libarchive" \
  ${EXTRA_CMAKE_ARGS} \
  ..

make -j"${CPU_COUNT}"
make install

# cvmfs overrides CMAKE_INSTALL_LIBDIR with lib64 on RedHat-flavoured Linux
if [ -d "${PREFIX}/lib64" ]; then
  mv "${PREFIX}"/lib64/* "${PREFIX}/lib/"
  rmdir "${PREFIX}/lib64"
fi

# Collect the license files of the statically linked vendored libraries
mkdir -p "${SRC_DIR}/vendored-licenses"
cp "${SRC_DIR}/externals/sha3/src/LICENSE" "${SRC_DIR}/vendored-licenses/LICENSE.sha3"
