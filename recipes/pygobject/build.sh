#!/usr/bin/env bash

./configure --with-python=${PYTHON} --prefix="${PREFIX}"
make check TEST_NAMES=test_gi
make install

