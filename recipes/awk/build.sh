#!/bin/bash -euo

set -xe

make CC="gcc -Wall"
if [ ! -d ${PREFIX}/bin ] ; then
    mkdir -p ${PREFIX}/bin
fi
mv a.out ${PREFIX}/bin/awk
