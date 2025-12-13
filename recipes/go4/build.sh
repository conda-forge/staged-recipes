#!/bin/bash
set -eumx -o pipefail
shopt -s failglob
# We do want to split words in $CMAKE_ARGS, so it must not be quoted!
# shellcheck disable=SC2086
# cmake -B build -S "${SRC_DIR}" -Dexamples=OFF $CMAKE_ARGS
# Actually using CMAKE_ARGS leads to missing /usr/lib64/libpthread_nonshared.a
cmake -B build -S "${SRC_DIR}" -Dexamples=OFF -DCMAKE_INSTALL_PREFIX="${PREFIX}"
cmake --build build -j"${CPU_COUNT}"
cmake --install build

cd "$PREFIX"
CHANGES="activate deactivate"
for CHANGE in $CHANGES; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}-go4.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${CHANGE}-${PKG_NAME}.sh"
done
