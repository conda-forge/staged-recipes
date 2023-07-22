set -euxo pipefail

mkdir -p build
cd build

export BUILD_MPI="FALSE"

if [[ "$mpi" != "nompi" ]]; then
  export BUILD_MPI="TRUE"
fi

export BUILD_CUDA="FALSE"

if [[ ${cuda_compiler_version} != "None" ]]; then
  export BUILD_CUDA="TRUE"
fi

cmake ${CMAKE_ARGS} -DCOMPILER=MANUAL -DOPENMP="TRUE" -DCUDA=${BUILD_CUDA} -DMPI=${BUILD_MPI} ${SRC_DIR}

make -j${CPU_COUNT}
make install
