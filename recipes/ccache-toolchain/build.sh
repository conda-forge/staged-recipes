#!/bin/bash

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/ccache_toolchain_${CHANGE}.sh"
done

mkdir -p ${PREFIX}/bin/conda_forge_ccache
cd ${PREFIX}/bin/conda_forge_ccache

for l in gfortran gcc g++ clang clang++
do
  ln -s ${PREFIX}/bin/ccache $l
done
