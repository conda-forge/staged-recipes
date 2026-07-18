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
  -DBUILTIN_EXTERNALS=ON \
  "-DBUILTIN_EXTERNALS_LIST=sha3" \
  "-DBUILTIN_EXTERNALS_EXCLUDE=json;libarchive" \
  ..

make -j"${CPU_COUNT}"
make install

# Collect the license files of the statically linked vendored libraries
mkdir -p "${SRC_DIR}/vendored-licenses"
cp "${SRC_DIR}/externals/sha3/src/LICENSE" "${SRC_DIR}/vendored-licenses/LICENSE.sha3"
