#!/usr/bin/env bash
# shellcheck disable=SC2154  # target_platform and PREFIX come from the build system

set -euxo pipefail

declare -a EXTRA_CMAKE_ARGS=()

if [[ "${target_platform}" == "linux-64" || "${target_platform}" == "osx-64" ]]; then
  # Left to itself EOS adds -msse4.2 to the global compile options, raising the
  # baseline for every object it builds. Its CRC32C implementation dispatches on
  # CPUID at runtime, so -mcrc32 alone still reaches the accelerated path on
  # hardware that has it.
  EXTRA_CMAKE_ARGS+=("-DNO_SSE=ON")
fi

# There is no git tree in the tarball, so genversion.sh cannot work these out.
IFS=. read -r version_major version_minor version_patch <<<"${EOS_VERSION}"

# C++20 rather than the C++17 EOS asks for: rocksdb >=10 headers use `using enum`
# and defaulted comparison operators, and eosxd3 includes <rocksdb/db.h>.
#
# FindGRPC, FindRocksDB and FindProtobuf3 search NO_DEFAULT_PATH under
# PATH_SUFFIXES ${CMAKE_INSTALL_LIBDIR}, so CMAKE_PREFIX_PATH never reaches them
# and they miss the prefix wherever GNUInstallDirs picks lib64. Hence both
# CMAKE_INSTALL_LIBDIR and the per-package *_ROOT flags.
# shellcheck disable=SC2086  # CMAKE_ARGS must word-split into separate flags
cmake -S "${SRC_DIR}" -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_CXX_STANDARD=20 \
  -DXROOTD_ROOT="${PREFIX}" \
  -DROCKSDB_ROOT="${PREFIX}" \
  -DGRPC_ROOT="${PREFIX}" \
  -DPROTOBUF_ROOT="${PREFIX}" \
  -DABSL_ROOT="${PREFIX}" \
  -DCLIENT=1 \
  -DUSE_SYSTEM_JWT_CPP=ON \
  -DUSE_SYSTEM_CLI11=ON \
  -DUSE_SYSTEM_BACKWARD_CPP=ON \
  -DCCACHE=OFF \
  -DBUILD_MANPAGES=0 \
  -DEOS_INSTALL_TUI=OFF \
  -DEOS_INSTALL_SYSCONFDIR="${PREFIX}/etc" \
  -DVERSION_MAJOR="${version_major}" \
  -DVERSION_MINOR="${version_minor}" \
  -DVERSION_PATCH="${version_patch}" \
  -DRELEASE="${EOS_RELEASE}" \
  "${EXTRA_CMAKE_ARGS[@]}" \
  ${CMAKE_ARGS}

cmake --build build -j"${CPU_COUNT}"
cmake --install build
