#!/bin/bash
set -eumx -o pipefail
shopt -s failglob

cmake -B build -S "${SRC_DIR}" -Dexamples=OFF -DCMAKE_INSTALL_PREFIX="${PREFIX}" "${CMAKE_ARGS}"
cmake --build build -j"${CPU_COUNT}"
cmake --install build

cd "$PREFIX"
CHANGES="activate deactivate"
for CHANGE in $CHANGES; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}-go4.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${CHANGE}-${PKG_NAME}.sh"
done
