#!/bin/bash
./configure --prefix="${PREFIX}"
make -j${NUM_CPUS}
make install
