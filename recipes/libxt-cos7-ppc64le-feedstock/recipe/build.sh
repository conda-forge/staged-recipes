#!/bin/bash

mkdir -p ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/usr
pushd ${PREFIX}/powerpc64le-conda_cos7-linux-gnu/sysroot/usr > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
