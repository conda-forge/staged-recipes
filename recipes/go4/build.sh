#!/bin/bash
set -eumx -o pipefail
shopt -s failglob

echo $PREFIX
echo $PKG_NAME
echo $SRC_DIR
echo $PWD
echo $BUILD_PREFIX
ls -lah $SRC_DIR

mkdir -p $PREFIX

cmake $SRC_DIR -Dexamples=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX}
make -j$(nproc)
make install

cd $PREFIX
CHANGES="activate deactivate"
for CHANGE in $CHANGES; do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}-go4.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${CHANGE}-${PKG_NAME}.sh"
done
