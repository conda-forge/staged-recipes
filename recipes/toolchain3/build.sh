#!/bin/bash

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/toolchain3_${CHANGE}.sh"
done

mkdir -p ${PREFIX}/bin/conda_forge
cd ${PREFIX}/bin/conda_forge
cp ${RECIPE_DIR}/conda-forge-cc cc

for l in ftn f90 fc f95 f77 gfortran gcc g++ clang clang++ ld
do
  ln -s cc $l
done
