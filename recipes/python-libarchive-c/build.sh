#!/bin/bash
export DETERMINISTIC_BUILD=1
export PYTHONHASHSEED=0

python setup.py install --single-version-externally-managed --record record.txt

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/libarchive-c_${CHANGE}.sh"
done
