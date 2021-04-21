#!/usr/bin/env bash

# Derived from cugraph build script, as seen here:
# https://github.com/rapidsai/cugraph/blob/db20b485cfc5399214afcff604b38493f38e83bf/build.sh#L137

# NOTE: it is assumed the RMM header-only sources have been downloaded from the
# multi-source "source:" section in the meta.yaml file.
# cmake must be able to find the RMM headers using find_path(). The RMM_ROOT env
# var is set so RMM_ROOT/include results in a valid dir for cmake to search.

# Set env var DUMP_LOGS_ON_ERROR=0 to suppress
DUMP_LOGS_ON_ERROR=${DUMP_LOGS_ON_ERROR:=1}

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
export VERBOSE_FLAG="-v"

# Use the nvcc wrapper installed with cudatoolkit, assumed to be first in PATH.
# This ensures nvcc calls the compiler in the conda env.
export CUDA_NVCC_EXECUTABLE=$(which nvcc)

# Manually specify the location of the cudatoolkit libs since cmake is not
# adding this lib dir to the link options.
CUDATK_LIB_DIR=$PREFIX/lib
export CXXFLAGS="${CXXFLAGS} -L${CUDATK_LIB_DIR}"

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
    if (( ${DUMP_LOGS_ON_ERROR} == 1 )); then
        echo "********************************************************************************"
        echo "* START OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeOutput.log"
        cat ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeOutput.log
        echo "* END OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeOutput.log"
        echo "********************************************************************************"
        echo "* START OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeError.log"
        cat ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeError.log
        echo "* END OF: ${CUGRAPH_SRC_DIR}/cpp/build/CMakeFiles/CMakeError.log"
        echo "********************************************************************************"
    fi
    exit ${ERRCODE}
fi

cmake --build "${LIBCUGRAPH_BUILD_DIR}" -j${PARALLEL_LEVEL} --target ${INSTALL_TARGET} ${VERBOSE_FLAG}

# FIXME: The v0.19.0a cugraph sources in the tarfile used on 2021-04-16 do not
# appear to have the update to generate the version_config.hpp file, so generate
# it here. If the final release of the v0.19 cugraph sources does have the
# generated file, this should still not cause harm. This should be removed for a
# 0.20+ build.
VERSION_CONFIG_IN='/*
 * Copyright (c) 2021, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#pragma once

#define CUGRAPH_VERSION_MAJOR @CUGRAPH_VERSION_MAJOR@
#define CUGRAPH_VERSION_MINOR @CUGRAPH_VERSION_MINOR@
#define CUGRAPH_VERSION_PATCH @CUGRAPH_VERSION_PATCH@
'
VERSION_CONFIG_OUT=${INSTALL_PREFIX}/include/cugraph/version_config.hpp
CMAKELISTS_TXT=${CUGRAPH_SRC_DIR}/cpp/CMakeLists.txt
CUGRAPH_VER_STRING=$(grep "project(CUGRAPH" ${CMAKELISTS_TXT}|awk '{print $3}')
MAJOR=$(echo "${CUGRAPH_VER_STRING}"|cut -d'.' -f1)
MINOR=$(echo "${CUGRAPH_VER_STRING}"|cut -d'.' -f2)
PATCH=$(echo "${CUGRAPH_VER_STRING}"|cut -d'.' -f3)
echo "${VERSION_CONFIG_IN}" > ${VERSION_CONFIG_OUT}
sed -i "s/@CUGRAPH_VERSION_MAJOR@/${MAJOR}/g" ${VERSION_CONFIG_OUT}
sed -i "s/@CUGRAPH_VERSION_MINOR@/${MINOR}/g" ${VERSION_CONFIG_OUT}
sed -i "s/@CUGRAPH_VERSION_PATCH@/${PATCH}/g" ${VERSION_CONFIG_OUT}
