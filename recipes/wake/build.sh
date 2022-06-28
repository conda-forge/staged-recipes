#!/bin/bash

make -j $CPU_COUNT
make  test
make  unittest
./bin/wake install $PREFIX
