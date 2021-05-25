#!/bin/bash

set -x

export MPICXX=mpicxx
export MFEM_PREFIX=$PREFIX
export MFEM_USE_MPI=YES

make config

cat config/config.mk

make lib -j${CPU_COUNT}
make install
