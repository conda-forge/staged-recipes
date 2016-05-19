#!/bin/bash


# This works for `setuptools`, but breaks `distutils`.
# Will need to figure out a better long term strategy.
cp "${RECIPE_DIR}/distutils.cfg" "${STDLIB_DIR}/distutils/distutils.cfg"

# Configure `pip`.
mkdir -p "${PREFIX}/etc"
cp "${RECIPE_DIR}/pip.conf" "${PREFIX}/etc/pip.conf"
