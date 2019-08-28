#!/bin/bash
# based on https://github.com/cp2k/cp2k/blob/master/tools/toolchain/Dockerfile.ubuntu_nompi
./tools/toolchain/install_cp2k_toolchain.sh \
    --mpi-mode=no                \
    --with-gcc=system            \
    --with-cmake=system          \
    --with-fftw=system           \
    --with-openblas=system       \
    --with-reflapack=system      \
    --with-gsl=system            \
    --with-hdf5=system           \
    --with-libxc=system          \
    --with-libxsmm=install       \
    --with-libint=system
