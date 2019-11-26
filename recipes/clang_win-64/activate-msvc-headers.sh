#!/bin/bash

set -x
MSVC_HEADERS_VERSION=14.11.25547

[ -z "${CI}" ] || export CONDA_BUILD_WINSDK=/tmp/cf-ci-winsdk

if [[ -z "${CONDA_BUILD_WINSDK}" ]]; then
    echo "CONDA_BUILD_WINSDK" is not set.
    return 0
fi

echo "By setting CONDA_BUILD_WINSDK, you are agreeing to the terms and conditions of the MSVC headers"

MSVC_HEADERS_DIR=${CONDA_BUILD_WINSDK}/msvc-${MSVC_HEADERS_VERSION}

if [[ ! -d "${MSVC_HEADERS_DIR}" ]]; then
    mkdir -p "${MSVC_HEADERS_DIR}"
    cd "${MSVC_HEADERS_DIR}"
    mkdir -p tmp
    pushd tmp
      curl -L -O https://www.nuget.org/api/v2/package/VisualCppTools.Community.VS2017Layout/${MSVC_HEADERS_VERSION}
      unzip -o ${MSVC_HEADERS_VERSION}
      find lib -type d -name "x86" -delete || true
      find lib -type d -name "arm" -delete || true
      mkdir -p ${MSVC_HEADERS_DIR}/include
      mkdir -p ${MSVC_HEADERS_DIR}/lib
      mv lib/native/lib/* ${MSVC_HEADERS_DIR}/lib/
      mv lib/native/include/* ${MSVC_HEADERS_DIR}/include/
      rm ${MSVC_HEADERS_VERSION}
    popd
    rm -rf tmp
fi
