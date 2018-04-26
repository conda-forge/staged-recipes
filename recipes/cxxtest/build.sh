#!/bin/bash

MYBINDIR="${PREFIX}/bin"
MYINCLUDEDIR="${PREFIX}/include"
MYSUFFIXDIR="lib/${PKG_NAME}-${PKG_VERSION}"
MYTARGETDIR="${PREFIX}/${MYSUFFIXDIR}"

mkdir -p "${MYBINDIR}"
mkdir -p "${MYINCLUDEDIR}/cxxtest"
mkdir -p "${MYTARGETDIR}"

cp -r ./* "${MYTARGETDIR}/"
ln "${MYTARGETDIR}"/cxxtest/* "${MYINCLUDEDIR}/cxxtest/"
cp "${RECIPE_DIR}/cxxtestgen" "${MYBINDIR}/"
