#!/bin/bash
set -ex

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    sed -i 's/@CHOST@/${CHOST}/g' ${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh
done
