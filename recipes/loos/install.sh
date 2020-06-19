#!/bin/sh -x
set -x

echo "Begin loos install.sh"
export CONDA_PREFIX=$BUILD_PREFIX
export RECIPE=1

scons PREFIX=$PREFIX install
