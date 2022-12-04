#!/bin/bash

python --version
touch ${PREFIX}/bin/testfile

set -x
echo "prefix=${PREFIX}"
#/home/conda/staged-recipes/build_artifacts/kedro-datasets_1670121074486/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placeh
echo "recipe_dir=${RECIPE_DIR}"
#/home/conda/staged-recipes-copy/recipes/kedro-datasets
echo "$(ls)"
cp "/home/conda/staged-recipes-copy/recipes/kedro-datasets/requirements.txt ${PREFIX}/requirements.txt"
echo "$(ls)"  
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
