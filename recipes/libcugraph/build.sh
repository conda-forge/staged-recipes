#!/usr/bin/env bash

# Derived from cugraph build script, as seen here:
# https://github.com/rapidsai/cugraph/blob/db20b485cfc5399214afcff604b38493f38e83bf/build.sh#L137

# NOTE: it is assumed the RMM header-only sources have been downloaded from the
# multi-source "source:" section in the meta.yaml file.
# cmake must be able to find the RMM headers using find_path(). The RMM_ROOT env
# var is set so RMM_ROOT/include results in a valid dir for cmake to search.

export CUGRAPH_SRC_DIR="${SRC_DIR}/cugraph"
export RMM_ROOT="${SRC_DIR}/rmm"
export LIBCUGRAPH_BUILD_DIR=${LIBCUGRAPH_BUILD_DIR:=${CUGRAPH_SRC_DIR}/cpp/build}
export GPU_ARCHS=ALL
export INSTALL_PREFIX=${PREFIX:=${CONDA_PREFIX}}
export BUILD_DISABLE_DEPRECATION_WARNING=ON
export BUILD_TYPE=Release
export BUILD_CPP_TESTS=OFF
export BUILD_CPP_MG_TESTS=OFF
export BUILD_STATIC_FAISS=OFF
export PARALLEL_LEVEL=${CPU_COUNT}
export INSTALL_TARGET=install
export VERBOSE_FLAG=""
# Use the nvcc wrapper installed via cudatoolkit, assumed to be first in PATH.
# This ensures nvcc calls the compiler in the conda env.
export CUDA_NVCC_EXECUTABLE=$(which nvcc)

mkdir -p ${LIBCUGRAPH_BUILD_DIR}
cd ${LIBCUGRAPH_BUILD_DIR}
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      -DGPU_ARCHS=${GPU_ARCHS} \
      -DDISABLE_DEPRECATION_WARNING=${BUILD_DISABLE_DEPRECATION_WARNING} \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DBUILD_STATIC_FAISS=${BUILD_STATIC_FAISS} \
      -DBUILD_TESTS=${BUILD_CPP_TESTS} \
      -DBUILD_CUGRAPH_MG_TESTS=${BUILD_CPP_MG_TESTS} \
      "${CUGRAPH_SRC_DIR}/cpp"

ERRCODE=$?
if (( ${ERRCODE} != 0 )); then
   echo "********************************************************************************"
   echo "* START OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeOutput.log"
   cat ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeOutput.log
   echo "* END OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeOutput.log"
   echo "********************************************************************************"
   echo "* START OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeError.log"
   cat ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeError.log
   echo "* END OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeError.log"
   echo "********************************************************************************"
   exit ${ERRCODE}
fi

cmake --build "${LIBCUGRAPH_BUILD_DIR}" -j${PARALLEL_LEVEL} --target ${INSTALL_TARGET} ${VERBOSE_FLAG}
