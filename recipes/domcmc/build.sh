#!/bin/bash

# install package
$PYTHON -m pip install --no-deps . -vv

# copy activate script that will be sourced upon env activation
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
