#!/bin/bash

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR
make
make test
make install

ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp ${RECIPE_DIR}/stare-activate.sh   ${ACTIVATE_DIR}/stare-activate.sh
cp ${RECIPE_DIR}/stare-deactivate.sh ${DEACTIVATE_DIR}/stare-deactivate.sh





