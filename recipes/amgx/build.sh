#!/usr/bin/env bash
set -euxo pipefail

# enable MPI for the parallel variants
if [[ -n "${mpi:-}" && "${mpi}" != "nompi" ]]; then
  MPI_ARGS="-DCMAKE_NO_MPI=OFF"
else
  MPI_ARGS="-DCMAKE_NO_MPI=ON"
fi

# configure
# pass CUDAARCHS explicitly (AmgX presets CMAKE_CUDA_ARCHITECTURES before
# project()), keeping only sm_70+ as supported upstream
CUDA_ARCHS=$(tr ';' '\n' <<< "${CUDAARCHS:?}" | awk '$0+0 >= 70' | paste -sd';')
cmake -B build -S . ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCHS}" \
  ${MPI_ARGS}

# build
cmake --build build --target amgx amgxsh -j"${CPU_COUNT}"

# install headers + libs; skip subdir rules (examples, tests, sample configs)
cmake -DCMAKE_INSTALL_LOCAL_ONLY=ON -P build/cmake_install.cmake

# drop static library
rm "$PREFIX/lib/libamgx.a"
