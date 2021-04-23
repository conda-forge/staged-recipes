#!/usr/bin/env bash

# Derived from RMM build script, as seen here:
# https://github.com/rapidsai/rmm/blob/branch-0.19/build.sh

# Set env var DUMP_LOGS_ON_ERROR=0 to suppress
DUMP_LOGS_ON_ERROR=${DUMP_LOGS_ON_ERROR:=1}

export RMM_SRC_DIR="${SRC_DIR}/rmm"
export LIBRMM_BUILD_DIR=${LIBRMM_BUILD_DIR:=${RMM_SRC_DIR}/build}
export INSTALL_PREFIX=${PREFIX:=${CONDA_PREFIX}}
export CUDA_STATIC_RUNTIME=OFF
export PER_THREAD_DEFAULT_STREAM=OFF
export BUILD_TESTS=OFF
export BUILD_BENCHMARKS=OFF
export BUILD_TYPE=Release
export VERBOSE_FLAG="-v"

mkdir -p ${LIBRMM_BUILD_DIR}
cd ${RMM_SRC_DIR}
cmake -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
      -DCUDA_STATIC_RUNTIME="${CUDA_STATIC_RUNTIME}" \
      -DPER_THREAD_DEFAULT_STREAM="${PER_THREAD_DEFAULT_STREAM}" \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DBUILD_TESTS=${BUILD_TESTS} \
      -DBUILD_BENCHMARKS=${BUILD_BENCHMARKS} \
      -B "${LIBRMM_BUILD_DIR}" \
      -S .

ERRCODE=$?
if (( ${ERRCODE} != 0 )); then
    if (( ${DUMP_LOGS_ON_ERROR} == 1 )); then
        echo "********************************************************************************"
        echo "* START OF: ${RMM_SRC_DIR}/build/CMakeFiles/CMakeOutput.log"
        cat ${RMM_SRC_DIR}/build/CMakeFiles/CMakeOutput.log
        echo "* END OF: ${RMM_SRC_DIR}/build/CMakeFiles/CMakeOutput.log"
        echo "********************************************************************************"
        echo "* START OF: ${RMM_SRC_DIR}/build/CMakeFiles/CMakeError.log"
        cat ${RMM_SRC_DIR}/build/CMakeFiles/CMakeError.log
        echo "* END OF: ${RMM_SRC_DIR}/build/CMakeFiles/CMakeError.log"
        echo "********************************************************************************"
    fi
    exit ${ERRCODE}
fi

cmake --build "${LIBRMM_BUILD_DIR}" --target install ${VERBOSE_FLAG}
