#!/usr/bin/env bash

INSTALL_DIR=$PREFIX/bin

make single
COMPILER=$GFORTRAN make

cp genesis2 $INSTALL_DIR

