#!/bin/bash

#set -e
set -x

# Get an updated config.sub and config.guess
cp ${BUILD_PREFIX}/share/gnuconfig/config.* .

# Set MPI compilers for parallel builds
if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  export CC=mpicc
  export FC=mpifort
  mpiexec="mpiexec --allow-run-as-root"
  # for cross compiling using openmpi
  export OPAL_PREFIX=$PREFIX
else
  export CC=$(basename ${CC})
  export FC=$(basename ${FC})
fi

# Adapted from libnetcdf-feedstock to fix issue with CMake and sysroot
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi


# Build shared library libtrexio
cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR="lib" \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DENABLE_HDF5=ON \
      -DBUILD_SHARED_LIBS=ON \
      ${CMAKE_PLATFORM_FLAGS[@]} \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}
make install

ctest -VV --output-on-failure -j${CPU_COUNT} || true

