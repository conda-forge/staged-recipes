#!/bin/sh

export GRPC_PYTHON_BUILD_WITH_CYTHON=1
export GRPC_PYTHON_CFLAGS=-std=c99
export GRPC_PYTHON_LDFLAGS=-std=c99

# set these so the default in setup.py are not used
export GRPC_PYTHON_CFLAGS=""
export GRPC_PYTHON_LDFLAGS=""

if [[ $(uname) == Darwin ]]; then
    # the makefile uses $AR for creating libraries, set it correctly here
    export AR="$LIBTOOL -no_warning_for_no_symbols -o"

    # we need a single set of openssl include files, the ones in PREFIX were
    # removed above
    export CFLAGS="${CFLAGS}"
    export CXXFLAGS="${CXXFLAGS}"

    # the Python extension has an unresolved _deflate symbol, link to libz to
    # resolve
    export LDFLAGS="${LDFLAGS} -lz"
fi

$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
