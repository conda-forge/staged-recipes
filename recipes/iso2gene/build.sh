#!/usr/bin/env bash
set -euxo pipefail

cmake -S "${SRC_DIR}" -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel "${CPU_COUNT:-1}"

install -d "${PREFIX}/bin"
install -m 755 build/iso2gene "${PREFIX}/bin/iso2gene"

doc_dir="${PREFIX}/share/doc/iso2gene"
install -d "${doc_dir}"
install -m 644 "${SRC_DIR}/LICENSE" "${doc_dir}/LICENSE"
install -m 644 "${SRC_DIR}/README.md" "${doc_dir}/README.md"
install -m 644 "${SRC_DIR}/THIRD_PARTY_NOTICES.txt" "${doc_dir}/THIRD_PARTY_NOTICES.txt"
cp -R "${SRC_DIR}/LICENSES" "${doc_dir}/LICENSES"
