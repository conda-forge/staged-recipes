#!/bin/bash

set -x

make config CXX=$CXX PREFIX=$PREFIX MFEM_USE_MPI=YES

cat config/config.mk

make lib -j${CPU_COUNT}
make install
