#!/bin/bash
set -ex

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    envsubst '$PKG_VERSION' < "${RECIPE_DIR}/${CHANGE}.sh" > "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

mkdir -p ${PREFIX}/bin
cp "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh" ${PREFIX}/bin/activate_emscripten.sh
