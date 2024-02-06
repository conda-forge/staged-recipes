#!/bin/bash
set -ex

CXXFLAGS="${CXXFLAGS} -D_POSIX_C_SOURCE=200809L"
$PYTHON setup.py install
