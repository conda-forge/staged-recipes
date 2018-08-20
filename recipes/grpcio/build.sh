#!/bin/bash

# set these so the default in setup.py are not used
export GRPC_PYTHON_LDFLAGS=""

export GRPC_PYTHON_BUILD_SYSTEM_ZLIB="True"
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL="True"
export GRPC_PYTHON_BUILD_SYSTEM_CARES="True"

if [[ `uname` == 'Darwin' ]]; then
    export PATH="$SRC_DIR:$PATH"
    cp $RECIPE_DIR/clang_wrapper.sh $SRC_DIR/clang
    chmod +x $SRC_DIR/clang
fi

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
