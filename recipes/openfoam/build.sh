#!/bin/bash
set -xeuf

WM_PROJECT_DIR=src/OpenFOAM-v2106

source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
