#!/bin/bash

set -x

export MFEM_CXX=mpicxx
export MFEM_HOST_CXX=mpicxx

make config
make lib -j${CPU_COUNT}
make install
