#!/usr/bin/env bash

tar xvf Laura.tar.gz

mkdir build

cmake -S Laura++ -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    ${CMAKE_ARGS}

cmake --build build --target install "-j${CPU_COUNT}"

# Put the license into a more predictable location
cp Laura++/LICENSE-2.0 .

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-laura.sh"

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-laura.sh"
