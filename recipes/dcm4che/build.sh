#!/usr/bin/env bash

set -e

mkdir -p "$PREFIX/share"

#curl https://www.dcm4che.org/maven2/org/dcm4che/dcm4che-assembly/5.33.1/dcm4che-assembly-5.33.1-bin.tar.gz | tar xz
    
rm -rf "$PREFIX/share/dcm4che"

cp -a $SRC_DIR/bin "$PREFIX/share/dcm4che"
cp -a $SRC_DIR/etc "$PREFIX/share/dcm4che"
cp -a $SRC_DIR/js "$PREFIX/share/dcm4che"
cp -a $SRC_DIR/lib "$PREFIX/share/dcm4che"
cp -a $SRC_DIR/LICENSE.txt "$PREFIX/share/dcm4che"
cp -a $SRC_DIR/README.md "$PREFIX/share/dcm4che"

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
