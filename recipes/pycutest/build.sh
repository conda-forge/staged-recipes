#! /usr/bin/env bash

set -euox pipefail

# install the python interface
${PYTHON} -m pip install . -vv --no-deps

# following build instructions from
# https://jfowkes.github.io/pycutest/_build/html/install.html

export ARCHDEFS=${SRC_DIR}/archdefs
export SIFDECODE=${SRC_DIR}/sifdecode
export MASTSIF=${SRC_DIR}/mastsif
export CUTEST=${SRC_DIR}/cutest

# fix hardcoded compilers
sed 's/^FORTRAN=.*/FORTRAN=$GFORTRAN/g' -i ${ARCHDEFS}/*compiler.*
sed 's/^CC=.*/CC=$GCC/g' -i ${ARCHDEFS}/*compiler.*

# build
pushd ${CUTEST}
${ARCHDEFS}/install_optrove < ${RECIPE_DIR}/install-options
popd

# fix hardcoded compilers in generated makefiles configs
sed 's/^FORTRAN\s*=.*/FORTRAN=$(GFORTRAN)/g' -i ${SIFDECODE}/makefiles/* ${CUTEST}/makefiles/*
sed 's/^CC\s*=.*/CC=$(GCC)/g' -i ${SIFDECODE}/makefiles/* ${CUTEST}/makefiles/*

# install everything under share
cp -r ${SIFDECODE} ${PREFIX}/share/sifdecode
cp -r ${CUTEST} ${PREFIX}/share/cutest
cp -r ${ARCHDEFS} ${PREFIX}/share/archdefs
cp -r ${MASTSIF} ${PREFIX}/share/mastsif

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for script in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${script}.d"
    cp "${RECIPE_DIR}/${script}.sh" "${PREFIX}/etc/conda/${script}.d/${PKG_NAME}_${script}.sh"
done
