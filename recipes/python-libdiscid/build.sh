#!/bin/sh

set -ex

export CYLP_USE_CYTHON=1

python setup.py install . -vvv
