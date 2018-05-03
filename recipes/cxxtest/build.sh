#!/bin/bash
MYBINDIR="${PREFIX}/bin"
MYINCLUDEDIR="${PREFIX}/include"
MYPYTHONDIR="${PREFIX}/python"

mkdir -p "${MYBINDIR}"
mkdir -p "${MYINCLUDEDIR}/cxxtest"
mkdir -p "${MYPYTHONDIR}"

cp -r ./cxxtest "${MYINCLUDEDIR}"
cp ${RECIPE_DIR}/cxxtestgen "${MYBINDIR}"

cd ./python
${PYTHON} setup.py install --single-version-externally-managed --record=record.txt
