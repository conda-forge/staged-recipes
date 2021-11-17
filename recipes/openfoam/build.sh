#!/bin/bash

set -xeuf

source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
