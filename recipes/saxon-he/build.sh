#!/bin/bash

export INSTALL_DIR=$PREFIX/lib/SaxonHE
mkdir -p $INSTALL_DIR

# Install built files
mv saxon-he-*.jar $INSTALL_DIR

mkdir -p $INSTALL_DIR/lib
mv lib/* $INSTALL_DIR/lib

mkdir -p $INSTALL_DIR/doc
mv doc/* $INSTALL_DIR/doc

mkdir -p $INSTALL_DIR/notices
mv notices/* $INSTALL_DIR/notices

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done