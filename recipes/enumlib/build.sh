#!/bin/bash
export FFLAGS=${FFLAGS}" -ffree-line-length-none -I${SRC_DIR}/symlib/src"
cd src

make
make enum.x
make polya.x

mkdir -p ${PREFIX}/bin
cp enum.x ${PREFIX}/bin/enum.x
cp polya.x ${PREFIX}/bin/polya.x
