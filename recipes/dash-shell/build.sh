#!/bin/bash

set -xe

./autogen.sh
./configure --prefix $PREFIX
./configure --help 
false
make  -j$CPU_COUNT
make  install
