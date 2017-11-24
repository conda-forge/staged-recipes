#!/usr/bin/env bash

./Configure -n $(uname|tr '[:upper:]' '[:lower:]')
make CFGL="-L./lib -ltirpc"

mkdir -p $CONDA_PREFIX/bin/
cp ./lsof $CONDA_PREFIX/bin/
