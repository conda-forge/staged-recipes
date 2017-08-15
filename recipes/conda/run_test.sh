#!/bin/bash

# Deactivate external conda.
source deactivate

# Add and configure special conda directories and files.
export CONDARC="$PREFIX/.condarc"
export CONDA_ENVS_DIRS="$PREFIX/envs"
export CONDA_PKGS_DIRS="$PREFIX/pkgs"
touch "$CONDARC"
mkdir "$CONDA_ENVS_DIRS"
mkdir "$CONDA_PKGS_DIRS"

# Activate the built conda.
source $PREFIX/bin/activate $PREFIX

# Run conda tests.
source ./test_conda.sh

# Deactivate the built conda when done.
# Not necessary, but a good test.
source deactivate
