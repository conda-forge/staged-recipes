#!/usr/bin/env bash

INSTALL_DIR=${PREFIX}/bin

make single
#COMPILER=$GFORTRAN make
COMPILER=gfortran make

mkdir -p ${INSTALL_DIR}
cp genesis2 ${INSTALL_DIR}

