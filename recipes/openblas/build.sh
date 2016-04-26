#!/bin/bash

OPTS="USE_THREAD=1 NUM_THREADS=128 DYNAMIC_ARCH=1"

make FC=gfortran $OPTS
make tests
make PREFIX=$PREFIX $OPTS install
