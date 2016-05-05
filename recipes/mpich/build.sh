#!/bin/bash
export MACOSX_DEPLOYMENT_TARGET=10.9
./configure --enable-shared --prefix=$PREFIX
make
make install
