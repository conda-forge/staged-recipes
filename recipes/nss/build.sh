#!/bin/bash

cd nss

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
install -v -m755 ${FOLDER}/lib/*.so "${PREFIX}/lib"
install -v -m644 ${FOLDER}/lib/{*.chk,libcrmf.a} "${PREFIX}/lib"

install -v -m755 -d "${PREFIX}/include/nss"
cp -v -RL {public,private}/nss/* "${PREFIX}/include/nss"
chmod -v 644 ${PREFIX}/include/nss/*
install -v -m755 ${FOLDER}/bin/{certutil,nss-config,pk12util} "${PREFIX}/bin"

install -v -m644 ${FOLDER}/lib/pkgconfig/nss.pc  "${PREFIX}/lib/pkgconfig"
