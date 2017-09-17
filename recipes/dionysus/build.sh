#!/bin/bash

export CXX=clang++
export CC=clang
export CXXFLAGS=-stdlib=libc++

python setup.py install --single-version-externally-managed --record record.txt
