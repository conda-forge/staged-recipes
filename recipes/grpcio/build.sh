#!/bin/sh
export GRPC_PYTHON_BUILD_WITH_CYTHON=1
export GRPC_PYTHON_CFLAGS=-std=c++11
export GRPC_PYTHON_LDFLAGS=-std=c++11
python setup.py install --single-version-externally-managed --record record.txt

