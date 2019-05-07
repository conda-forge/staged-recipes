#!/bin/bash

################################################
# Use `asm-generic/socket.h` from distro.      #
# Needed to ensure `SO_REUSEPORT` is defined.  #
# This feature was added in Linux kernel 3.9.  #
# However RHEL 6 and CentOS 6 backported it.   #
# The sysroot compilers get in the way so we   #
# use this header from this system to define   #
# `SO_REUSEPORT`.                              #
#                                              #
# ref: https://lwn.net/Articles/542629/        #
################################################
CONDA_BUILD_SYSROOT="$(${CC} --print-sysroot)"
cp /usr/include/asm-generic/socket.h "${CONDA_BUILD_SYSROOT}/usr/include/asm-generic/socket.h"

make -j${CPU_COUNT} CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart"
make install PREFIX="${PREFIX}"

# Delete the static library as it is quite large.
# Should halve the package size.
rm "${PREFIX}/lib/libnccl_static.a"
