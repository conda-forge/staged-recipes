#!/bin/bash

set -x -e

export CC=`which h5c++`

pushd sucpp; make clean; make test; make main; make api; popd
pushd sucpp; ./test_su; ./test_api; popd

$PYTHON -m pip install . --no-deps -vv
