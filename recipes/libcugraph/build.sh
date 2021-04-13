#!/usr/bin/env bash

# Derived from cugraph build script, as seen here:
# https://github.com/rapidsai/cugraph/blob/db20b485cfc5399214afcff604b38493f38e83bf/build.sh#L137

CUGRAPH_SRC_DIR=FIXME: set this!
LIBCUGRAPH_BUILD_DIR=${LIBCUGRAPH_BUILD_DIR:=${CUGRAPH_SRC_DIR}/cpp/build}
GPU_ARCH=ALL
INSTALL_PREFIX=${PREFIX:=${CONDA_PREFIX}}
BUILD_DISABLE_DEPRECATION_WARNING=ON
BUILD_TYPE=Release
BUILD_CPP_TESTS=OFF
BUILD_CPP_MG_TESTS=OFF
BUILD_STATIC_FAISS=OFF
PARALLEL_LEVEL=${CPU_COUNT}
INSTALL_TARGET=install
VERBOSE_FLAG=""

# NOTE: it is assumed the RMM header-only sources have been downloaded from the
# multi-source "source:" section in the meta.yaml file.
#
# cmake must be able to find the RMM headers using find_path(). The RMM_ROOT env
# var can be set so RMM_ROOT/include results in a valid dir for cmake to search.
mkdir -p ${LIBCUGRAPH_BUILD_DIR}
cd ${LIBCUGRAPH_BUILD_DIR}
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      ${GPU_ARCH} \
      -DDISABLE_DEPRECATION_WARNING=${BUILD_DISABLE_DEPRECATION_WARNING} \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DBUILD_STATIC_FAISS=${BUILD_STATIC_FAISS} \
      -DBUILD_TESTS=${BUILD_CPP_TESTS} \
      -DBUILD_CUGRAPH_MG_TESTS=${BUILD_CPP_MG_TESTS} \
      ${CUGRAPH_SRC_DIR}/cpp
cmake --build "${LIBCUGRAPH_BUILD_DIR}" -j${PARALLEL_LEVEL} --target ${INSTALL_TARGET} ${VERBOSE_FLAG}
