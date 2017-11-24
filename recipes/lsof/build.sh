#!/usr/bin/env bash
./Configure -n $(uname|tr '[:upper:]' '[:lower:]')
make -j${CPU_COUNT}
mkdir -p $CONDA_PREFIX/bin/
cp ./lsof $CONDA_PREFIX/bin/
