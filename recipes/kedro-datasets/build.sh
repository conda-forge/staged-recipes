#!/bin/bash

python --version
touch ${PREFIX}/bin/testfile

set -x
echo "prefix=${PREFIX}"
echo "recipe_dir=${RECIPE_DIR}"
echo "$(ls)"
cp "/home/conda/staged-recipes-copy/recipes/kedro-datasets/requirements.txt ${PREFIX}/requirements.txt"
cp "/home/conda/staged-recipes-copy/recipes/kedro-datasets/requirements.txt ${RECIPE_DIR}/requirements.txt"
echo "$(ls)"  
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
