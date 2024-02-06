#!/bin/bash
set -ex

CXXFLAGS="${CXXFLAGS} -D_POSIX_C_SOURCE=199309L"
$PYTHON setup.py install