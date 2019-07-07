#!/bin/bash

mkdir -p ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr
pushd ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
