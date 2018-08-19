#!/bin/bash

# set these so the default in setup.py are not used
export GRPC_PYTHON_LDFLAGS=""

export GRPC_PYTHON_BUILD_SYSTEM_ZLIB="True"
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL="True"
# export GRPC_PYTHON_BUILD_SYSTEM_CARES="True"

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
