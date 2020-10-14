#!/usr/bin/env bash

INSTALL_DIR=$PREFIX/bin

make single
COMPILER=gfortran make

cp genesis2 $INSTALL_DIR

