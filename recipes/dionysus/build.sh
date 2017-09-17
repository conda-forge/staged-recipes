#!/bin/bash

export CXX=clang++
export CC=clang

python setup.py install --single-version-externally-managed --record record.txt
