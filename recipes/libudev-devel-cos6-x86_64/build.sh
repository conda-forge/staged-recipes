#!/bin/bash

mkdir -p ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr
pushd ${PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .

# For some reason /usr/lib64/libudev.so is relative linked to /lib64/libudev.so.0.5.1
# and not /usr/lib64/libudev.so.0.5.1
# since our sysroot doesn't have /lib64, we must remake the link ourselves
cd lib64
rm libudev.so
ln -s libudev.so.0.5.1 libudev.so

