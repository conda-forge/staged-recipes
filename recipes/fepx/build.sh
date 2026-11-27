#!/bin/bash
# This file is part of the FEPX software package.
# Copyright (C) 1996-2026, DPLab, ACME Lab, CNRS.
# See the COPYING file in the top-level directory.

set -euxo pipefail

# - MPI: the variant's Open MPI or MPICH, through its Fortran wrapper;
# - HDF5: the serial library (hdf5 nompi), required (FEPX_ENABLE_HDF5=ON), found
#   through its CMake package file (which needs a C compiler); the test suite is
#   not built (it needs Python, NumPy and the HDF5 tools);
# - run paths: set by conda itself (FEPX_INSTALL_RPATH=OFF).
# Cross-compilation (osx-arm64 from osx-64): Open MPI's Fortran wrapper is a
# program, so that of the build machine is used, pointed to the target's Open MPI
# (OPAL_PREFIX); MPICH's wrapper is a script, run from the host prefix.
mpifort="${PREFIX}/bin/mpifort"
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" && "${mpi}" == "openmpi" ]]; then
  export OPAL_PREFIX="${PREFIX}"
  mpifort="${BUILD_PREFIX}/bin/mpifort"
fi
cmake -S src -B build ${CMAKE_ARGS:-} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DMPI_Fortran_COMPILER="${mpifort}" \
  -DFEPX_ENABLE_HDF5=ON \
  -DFEPX_INSTALL_RPATH=OFF \
  -DBUILD_TESTING=OFF

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
