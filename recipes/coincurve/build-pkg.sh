#!/bin/bash

set -eox pipefail

rm -rf coincurve.egg-info
rm -rf libsecp256k1

if [[ "${PKG_NAME: -7}" == "-shared" ]]; then
  export SECP256K1_SHARED_LIBS="1"
else
  export SECP256K1_SHARED_LIBS="0"
fi

if [[ "OSTYPE" == "linux"* ]]; then
  ${PYTHON} ${RECIPE_DIR}/compose_cffi_files.py
fi

${PYTHON} -m pip install --use-pep517 . -vvv
