#!/bin/bash
set -ex

# QE's CMake helpers expect a preprocessor named `cpp` on PATH.
ln -s $CPP $BUILD_PREFIX/cpp

QE_SRC=${SRC_DIR}/external/qe
QE_BUILD=${QE_SRC}/build

# --- Stage 1: build QE libraries (no install).
# koopmans-qe-utils links against QE's internal static libs and `.mod`
# files. Our three `.x` binaries only need a subset of QE's library
# targets, so we build just those — not QE's own executables.
cmake -S ${QE_SRC} -B ${QE_BUILD} \
    -DCMAKE_BUILD_TYPE=RelwithDebInfo \
    -DCMAKE_Fortran_FLAGS_RELWITHDEBINFO="-O2 -g -fbacktrace" \
    -DQE_ENABLE_MPI=ON \
    -DQE_ENABLE_OPENMP=ON \
    -DQE_ENABLE_SCALAPACK=ON \
    -DQE_ENABLE_HDF5=ON

# The target list mirrors the libraries FindEspresso.cmake requires
# (in koopmans-qe-utils/cmake/FindEspresso.cmake). Keep them in sync.
cmake --build ${QE_BUILD} -j ${CPU_COUNT} --target \
    qe_pw qe_pp qe_modules qe_modules_c \
    qe_fftx qe_fftx_c qe_utilx qe_utilx_c qe_upflib \
    qe_lax qe_xclib qe_libbeef qe_xml qe_devxlib qe_dftd3 \
    qe_device_lapack qe_kssolver_dense mbd

# --- Stage 2: build and install koopmans-qe-utils.
cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=RelwithDebInfo \
    -DCMAKE_Fortran_FLAGS_RELWITHDEBINFO="-O2 -g -fbacktrace" \
    -DQE_ROOT=${QE_SRC} \
    -DQE_ENABLE_MPI=ON \
    -DQE_ENABLE_OPENMP=ON \
    -DQE_ENABLE_SCALAPACK=ON \
    -DQE_ENABLE_HDF5=ON

cmake --build build -j ${CPU_COUNT}
cmake --install build
