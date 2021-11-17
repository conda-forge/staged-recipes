#!/bin/bash

export WM_MPLIB=OPENMPI
source src/OpenFOAM-v2106/etc/bashrc

foamSystemCheck

foam

./Allwmake -s -l
