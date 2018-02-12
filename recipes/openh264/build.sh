#!/bin/bash

make PREFIX=$PREFIX -j${CPU_COUNT}
make PREFIX=$PREFIX install

mkdir -p -m755 -v "$PREFIX"/bin
install -m755 -v h264dec "$PREFIX"/bin/h264dec
install -m755 -v h264enc "$PREFIX"/bin/h264enc
