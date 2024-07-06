#!/usr/bin/env bash

set -ex

pre_install_dir="${SRC_DIR}"/pre-install
mkdir -p "${SRC_DIR}"/build-release
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
mkdir -p "$SRC_DIR"/test-release
cp -r "$SRC_DIR"/build-release/bin "$SRC_DIR"/test-release
find "${pre_install_dir}" -name '*[Gg][Tt]est*' -print0 | while IFS= read -r -d '' file; do
  tar cf - "${file}" | (cd "$SRC_DIR"/test-release && tar xf - --transform='s,^.*/,,')
  rm -rf "${file}"
done

# Transfer pre-install to PREFIX
(cd "${pre_install_dir}" && tar cf - ./* | (cd "${PREFIX}" && tar xvf -))
