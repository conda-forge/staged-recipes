#!/bin/sh
export GRPC_PYTHON_BUILD_WITH_CYTHON=1
python setup.py install --single-version-externally-managed --record record.txt

