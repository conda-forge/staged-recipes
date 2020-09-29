#!/bin/bash

# Build
mkdir build && cd build
CXX=g++ CC=gcc cmake ..
make install
cd ..
