#!/bin/bash
cd V3.0/source
${FC} FE2ATmap_V3.0.f90 -o FE2ATmap
mkdir -p ${PREFIX}/bin
cp FE2ATmap ${PREFIX}/bin/FE2ATmap
cd ..
cp util/extractDisp.py ${PREFIX}/bin/extractDisp.py
