#!/bin/bash

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${RECIPE_DIR}"/activate.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
