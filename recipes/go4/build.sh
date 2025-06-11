#!/bin/bash
set -eumx -o pipefail
shopt -s failglob
shopt -s globstar

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

export PYTHONPATH=""
export ROOT_INCLUDE_PATH=""
now_change="activate"
source "${PREFIX}/etc/conda/${now_change}.d/${now_change}-${PKG_NAME}.sh"
