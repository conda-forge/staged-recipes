#!/bin/bash

./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make -j ${CPU_COUNT} check
make -j ${CPU_COUNT} install
