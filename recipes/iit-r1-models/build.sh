#!/bin/bash

rm -rf build

cmake ${CMAKE_ARGS} -S . -B build -GNinja  \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_PREFIX_PATH="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release

cmake --build build --config Release

cmake --build build --config Release --target install

# Generate and copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
multisheller ${RECIPE_DIR}/activate.msh --output ./activate
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "activate.bash" "${PREFIX}/etc/conda/activate.d/iit-r1-models_activate.sh"

multisheller ${RECIPE_DIR}/deactivate.msh --output ./deactivate
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "deactivate.bash" "${PREFIX}/etc/conda/deactivate.d/iit-r1-models_deactivate.sh"
