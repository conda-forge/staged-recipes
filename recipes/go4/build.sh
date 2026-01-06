#!/bin/bash
set -eumx -o pipefail
shopt -s failglob

# take out an argument from CMAKE_ARGS...
read -r -a CMAKE_ARGS_ARRAY <<< "$CMAKE_ARGS"
echo "CMAKE_ARGS has ${#CMAKE_ARGS_ARRAY[@]} arguments"
echo "Leaving out ${CMAKE_ARGS_ARRAY[14]}"
CMAKE_ARGS="${CMAKE_ARGS_ARRAY[*]:0:14} ${CMAKE_ARGS_ARRAY[*]:15}"

# We do want to split words in $CMAKE_ARGS, so it must not be quoted!
# shellcheck disable=SC2086
cmake -B build -S "${SRC_DIR}" -Dexamples=OFF $CMAKE_ARGS
cmake --build build -j"${CPU_COUNT}"
cmake --install build

cd "$PREFIX"
CHANGES="activate deactivate"
for CHANGE in $CHANGES; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}-go4.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${CHANGE}-${PKG_NAME}.sh"
done
