#!/bin/bash
MYBINDIR="${PREFIX}/bin"
MYINCLUDEDIR="${PREFIX}/include"
MYPYTHONDIR="${PREFIX}/python"

mkdir -p "${MYBINDIR}"
mkdir -p "${MYINCLUDEDIR}/cxxtest"
mkdir -p "${MYPYTHONDIR}"

cp -r "./cxxtest/" "${MYINCLUDEDIR}"
cp -r "./bin/" "${PREFIX}/"
cp -r "./python/" "${PREFIX}/"
