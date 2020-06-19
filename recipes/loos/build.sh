#!/bin/sh -x
# This install script is intended for conda-forge, and assumes the conda env
# is already set up. If you need to set up a conda env, I suggest running
# conda_build.sh instead.
set -x

echo "Begin loos build.sh"
export CONDA_PREFIX=$BUILD_PREFIX
export RECIPE=1

scons PREFIX=$PREFIX -j $CPU_COUNT
