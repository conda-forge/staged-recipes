#!/bin/bash -euo

# Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
# This causes them to be run on environment [de]activation.
# https://github.com/mamba-org/mamba/blob/master/libmamba/src/core/activation.cpp#L32-L47

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}-${CHANGE}.sh"
done
