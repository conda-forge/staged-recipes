#!/bin/bash

cd nss

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"

make    \
    USE_64=1 \
    PREFIX="${PREFIX}" \
    NSPR_PREFIX="${PREFIX}" \
    NSPR_INCLUDE_DIR="${PREFIX}/include/nspr" \
    C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/nspr" \
    LIBRARY_PATH="${PREFIX}/lib" \
    USE_SYSTEM_ZLIB=1 \
    NSS_USE_SYSTEM_SQLITE=1 \
    NS_USE_GCC=1 \
    NSDISTMODE='copy' \
    all latest

cd ../dist
FOLDER=$(<latest)
cd $FOLDER

cp -rL bin "${PREFIX}"
cp -rL lib "${PREFIX}"
