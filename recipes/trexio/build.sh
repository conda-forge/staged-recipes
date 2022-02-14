#!/bin/bash

set -e
set -x

./configure --prefix="${PREFIX}"

#make -j "${CPU_COUNT}" V=1 
make -j 8 V=1 

