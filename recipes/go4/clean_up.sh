#!/bin/bash
set -eumx -o pipefail
shopt -s globstar

echo $PREFIX
echo $PKG_NAME
echo $SRC_DIR
echo $PWD
echo $BUILD_PREFIX

pushd $PREFIX
tmp_prefixes="${BUILD_PREFIX} ${SRC_DIR}"
for replace_prefix in $tmp_prefixes; do
    echo "${replace_prefix}"
    sed -i "s|${replace_prefix}|${PREFIX}|g" **/*.h
    sed -i "s|${replace_prefix}|${PREFIX}|g" **/*.cmake
    sed -i "s|${replace_prefix}|${PREFIX}|g" **/*.txt
    sed -i "s|${replace_prefix}|${PREFIX}|g" **/*Makefile*
    sed -i "s|${replace_prefix}|${PREFIX}|g" go4login
done
popd
