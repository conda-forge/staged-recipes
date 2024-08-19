#!/usr/bin/env bash

set -ex

build_dir="${SRC_DIR}"/build-release
test_release_dir="${SRC_DIR}"/test-release

mkdir -p "${build_dir}"
pushd "${SRC_DIR}"/build-release
  cmake -S "${SRC_DIR}" -B . \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
  -D toolbox_BUILD_SHARED_LIBS=ON \
  -D toolbox_BUILD_TESTS=ON \
  -G Ninja
  cmake --build . -- -j"${CPU_COUNT}"
  cmake --build . --target toolbox-test
  cmake --install .
popd

# Prepare test area
mkdir -p "${test_release_dir}"
cp -r "${build_dir}"/bin "${test_release_dir}"
cd "${PREFIX}"
  find . -name '*[Gg][Tt]est*' -print0 | while IFS= read -r -d '' file; do
    tar cf - "${file}" | (cd "${test_release_dir}" && tar xf -)
    rm -rf "${file}"
  done
cd "${SRC_DIR}"

rm -rf "${build_dir}"
