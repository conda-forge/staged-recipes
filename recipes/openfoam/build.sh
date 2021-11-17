#!/bin/bash

set -x

export LD_LIBRARY_PATH=${PREFIX}/lib

source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
