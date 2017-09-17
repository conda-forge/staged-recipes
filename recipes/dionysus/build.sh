#!/bin/bash

export CXX=clang++
export CC=clang
export CXXFLAGS=-stdlib=libc++
export LDFLAGS=-lc++abi

python setup.py install --single-version-externally-managed --record record.txt
