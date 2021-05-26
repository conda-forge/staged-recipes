#!/bin/bash

set -x

make config CXX=$CXX PREFIX=$PREFIX MFEM_SHARED=YES MFEM_STATIC=NO MFEM_USE_MPI=YES CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" LIBS="$LIBS" HYPRE_OPT="-I$PREFIX/include"

cat config/config.mk

make lib -j${CPU_COUNT}
make install

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make test
fi
