#!/bin/bash

cmake -S $SRC_DIR -DBUILD_SHARED_LIBS=YES -DCMAKE_INSTALL_PREFIX=$PREFIX  
make
make test
make install

ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp ${RECIPE_DIR}/stare-activate.sh   ${ACTIVATE_DIR}/stare-activate.sh
cp ${RECIPE_DIR}/stare-deactivate.sh ${DEACTIVATE_DIR}/stare-deactivate.sh





