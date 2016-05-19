#!/bin/bash


# This works for `setuptools`, but breaks `distutils`.
# Will need to figure out a better long term strategy.
cp "${RECIPE_DIR}/distutils.cfg" "${STDLIB_DIR}/distutils/distutils.cfg"

# Configure `pip`.
mkdir -p "${PREFIX}/etc"
cp "${RECIPE_DIR}/pip.conf" "${PREFIX}/etc/pip.conf"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/python-toolchain_${CHANGE}.sh"
done
