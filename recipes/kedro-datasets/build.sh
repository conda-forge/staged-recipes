#!/bin/bash

python --version
touch ${PREFIX}/bin/testfile

set -x
echo "prefix=${PREFIX}"
echo "recipe_dir=${RECIPE_DIR}"
echo "$(ls)"
cp "${RECIPE_DIR}/requirements.txt $PREFIX/
echo "$(ls)"  
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
