#!/bin/bash

 if [[ "$(uname)" == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.9
fi

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py install --prefix=$PREFIX
