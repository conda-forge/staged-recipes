#!/bin/bash

set -x

make config CXX=$CXX PREFIX=$PREFIX MFEM_SHARED=YES MFEM_STATIC=NO MFEM_USE_MPI=YES MFEM_USE_METIS_5=YES CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" LIBS="$LIBS" HYPRE_OPT="-I$PREFIX/include"

cat config/config.mk

make lib -j${CPU_COUNT}
make install

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  if [[ "$mpi" == "openmpi" ]]; then
    export OMPI_MCA_plm=isolated
    export OMPI_MCA_btl_vader_single_copy_mechanism=none
    export OMPI_MCA_rmaps_base_oversubscribe=yes
    export OMPI_ALLOW_RUN_AS_ROOT=1
    export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
  fi
  make check
fi
