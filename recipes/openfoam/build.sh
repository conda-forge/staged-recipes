#!/bin/bash
set -xeuf

pwd
ls
pushd src/
pwd
ls

source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
