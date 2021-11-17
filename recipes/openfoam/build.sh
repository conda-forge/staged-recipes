#!/bin/bash
set -xeuf


pushd src/

source OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
