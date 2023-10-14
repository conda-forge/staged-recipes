#!/bin/bash
cd v1.3
make
mkdir -p ${PREFIX}/bin
cp nanoSCULPT ${PREFIX}/bin/nanoSCULPT
