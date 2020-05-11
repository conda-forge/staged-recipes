#!/bin/sh -x
set -x

echo "Begin loos install.sh"
export CONDA_PREFIX=$BUILD_PREFIX

scons PREFIX=$PREFIX install
