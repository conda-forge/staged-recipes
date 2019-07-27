#!/bin/bash

./configure
make -j${CPU_COUNT}
make install
