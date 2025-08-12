#!/bin/bash

./configure --prefix=$PREFIX
make all CXXFLAGS="-g -O3"
make check
make install
