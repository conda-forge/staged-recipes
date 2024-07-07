#!/usr/bin/env bash

set -ex

build_dir="${SRC_DIR}"/build-release
pre_install_dir="${SRC_DIR}"/pre-install
test-release_dir="${SRC_DIR}"/test-release

mkdir -p "${build_dir}"
mkdir -p "${pre_install_dir}"
cd "${SRC_DIR}"/build-release
  # Downloads and install toolbox as a static lib, make sure to remove it
  cmake -S "${SRC_DIR}" -B . \
  -D CMAKE_INSTALL_PREFIX="${pre_install_dir}" \
  -D bip3x_BUILD_SHARED_LIBS=ON \
  -D bip3x_BUILD_JNI_BINDINGS=ON \
  -D bip3x_BUILD_C_BINDINGS=ON \
  -D bip3x_USE_OPENSSL_RANDOM=ON \
  -D bip3x_BUILD_TESTS=ON \
  -G Ninja
  cmake --build . -- -j"${CPU_COUNT}"
  cmake --install .
cd "${SRC_DIR}"

# Post-install toolbox removal
find "${pre_install_dir}" -name '*toolbox*' -print0 | while IFS= read -r -d '' file; do
  rm -rf "${file}"
done

# Prepare test area
mkdir -p "${test-release_dir}"
cp -r "${build_dir}"/bin "${test-release_dir}"
find "${pre_install_dir}" -name '*[Gg][Tt]est*' -print0 | while IFS= read -r -d '' file; do
  tar cf - "${file}" | (cd "${test-release_dir}" && tar xf - --transform='s,^.*/,,')
  rm -rf "${file}"
done

# Fix rpath for test binary
if [[ "${build_platform}" == "osx-64" ]]; then
  install_name_tool -add_rpath "${PREFIX}/lib" "${test-release_dir}"/bin/*
else
  patchelf --set-rpath "${PREFIX}/lib" "${test-release_dir}"/bin/*
fi

# Transfer pre-install to PREFIX
(cd "${pre_install_dir}" && tar cf - ./* | (cd "${PREFIX}" && tar xvf -))
