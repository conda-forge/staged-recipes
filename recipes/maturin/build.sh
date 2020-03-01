#!/bin/bash

set -ex

if [ `uname` == Darwin ]; then
  export MACOSX_DEPLOYMENT_TARGET=10.13
fi

$PYTHON -m pip install . --no-deps --ignore-installed -vv
