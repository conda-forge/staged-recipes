#!/bin/bash

mkdir -p ${PREFIX}/x86_64-conda-linux-gnu/sysroot
pushd ${PREFIX}/x86_64-conda-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
mkdir -p usr/include
cp -Rf "${SRC_DIR}"/binary-tzdata/* usr/
cp -Rf "${SRC_DIR}"/binary-kernel-headers/include/* usr/include/
cp -Rf "${SRC_DIR}"/binary-glibc-headers/include/* usr/include/
cp -Rf "${SRC_DIR}"/binary-glibc-devel/* usr/
cp -Rf "${SRC_DIR}"/binary-glibc-common/* .

mv lib64 lib
mv usr/lib64/* usr/lib/
rm -rf usr/lib64
ln -s $PWD/lib $PWD/lib64
ln -s $PWD/usr/lib $PWD/usr/lib64
