#!/usr/bin/env bash

set -e

mkdir -p "$PREFIX/share"
    
rm -rf "$PREFIX/share/dcm4che"
mkdir -p "$PREFIX/share/dcm4che"

cp -r $SRC_DIR/bin "$PREFIX/share/dcm4che"
cp -r $SRC_DIR/etc "$PREFIX/share/dcm4che"
cp -r $SRC_DIR/js "$PREFIX/share/dcm4che"
cp -r $SRC_DIR/lib "$PREFIX/share/dcm4che"
cp $SRC_DIR/LICENSE.txt "$PREFIX/share/dcm4che"
cp $SRC_DIR/README.md "$PREFIX/share/dcm4che"


# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done