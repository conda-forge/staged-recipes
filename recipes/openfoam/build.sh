#!/bin/bash
set -xeuf


pushd src/

source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
