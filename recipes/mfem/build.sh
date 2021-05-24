#!/bin/bash

set -x

export MFEM_CXX=mpicxx
export MFEM_HOST_CXX=mpicxx
export MFEM_PREFIX=$PREFIX

make config
make lib -j${CPU_COUNT}
make install
