#!/bin/bash
set -e

echo "**************** M E T I S  B U I L D  S T A R T S  H E R E ****************"

mkdir -p $PREFIX/metis-aster

make config \
     prefix=$PREFIX/metis-aster

make
make install

echo "**************** M E T I S  B U I L D  E N D S  H E R E ****************"