#!/bin/bash

pushd dd || exit 1
pushd cudd-3.0.0 || exit 1
autoreconf -vfi
./configure \
  CFLAGS="-fPIC -std=c99"
make -j "$CPU_COUNT"
popd || exit 1

export DD_CUDD=1
export DD_CUDD_ZDD=1
$PYTHON -m pip install . --no-deps -vv \
  --use-pep517 --no-build-isolation
popd || exit 1
