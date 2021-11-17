#!/bin/bash

set -x

source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
