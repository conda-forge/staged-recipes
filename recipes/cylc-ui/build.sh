#!/bin/bash

# https://docs.conda.io/projects/conda-build/en/latest/resources/build-scripts.html

# Env vars (more at https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html#env-vars)
# $PREFIX = Build prefix to which the build script should install.
# $RECIPE_DIR = Directory of the recipe.
# $SRC_DIR = Path to where source is unpacked or cloned.
# $STDLIB_DIR = Python standard library location.

cp -r "${SRC_DIR}" "$PREFIX"
