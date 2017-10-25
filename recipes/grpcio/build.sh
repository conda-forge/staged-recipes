#!/bin/sh
export GRPC_PYTHON_BUILD_WITH_CYTHON=1
export GRPC_PYTHON_CFLAGS=-std=c99
export GRPC_PYTHON_LDFLAGS=-std=c99
python setup.py install --single-version-externally-managed --record record.txt

