#!/bin/bash

set -ex

mkdir -p "${PREFIX}/cuda-compat"

# Unlike the other CUDA compat redistributables, this one unpacks into "compat_orin".
COMPAT_DIR=compat_orin

check-glibc ${COMPAT_DIR}/*.so*

cp -vd ${COMPAT_DIR}/*.so* "${PREFIX}/cuda-compat/"
