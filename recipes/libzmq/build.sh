#!/usr/bin/env bash

# --- Functions ---

function configure_platform() {
  case "${target_platform}" in
    linux-64)
      SYSROOT_ARCH="x86_64"
      ;;

    linux-aarch64)
      SYSROOT_ARCH="aarch64"
      ;;

    linux-ppc64le)
      SYSROOT_ARCH="powerpc64le"
      ;;

    osx-64)
      SYSROOT_ARCH="osx_64"
      ;;
  esac
}

function configure_cmake() {
  local build_dir=$1
  local install_dir=$2

  local current_dir
  current_dir=$(pwd)


  mkdir -p "${build_dir}"
  cd "${build_dir}"
    cmake "${SRC_DIR}" -Wno-dev \
      -D CMAKE_INSTALL_PREFIX="${install_dir}" \
      "${EXTRA_CMAKE_ARGS[@]}" \
      -G Ninja
  cd "${current_dir}"
}

function cmake_build_install() {
  local build_dir=$1

  local current_dir
  current_dir=$(pwd)

  cd "${build_dir}"
    cmake --build . -- -j"${CPU_COUNT}"
    cmake --install .
  cd "${current_dir}"
}

# --- Main ---

set -euxo pipefail

cmake_build_dir="${SRC_DIR}/build-release"

export LIBSODIUM_ROOT="${PREFIX}"

configure_platform
mkdir -p "${cmake_build_dir}"
# EXTRA_CMAKE_ARGS=("${CMAKE_ARGS}")
EXTRA_CMAKE_ARGS+=( \
  "-DBUILD_STATIC=OFF" \
  "-DZMQ_BUILD_TESTS=OFF" \
  "-DENABLE_CURVE=ON" \
  "-DWITH_LIBSODIUM=ON" \
  "-DENABLE_LIBSODIUM_RANDOMBYTES_CLOSE=ON" \
)
configure_cmake "${cmake_build_dir}" "${PREFIX}"
cmake_build_install "${cmake_build_dir}"
