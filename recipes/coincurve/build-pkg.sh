#!/bin/bash

set -eox pipefail

rm -rf coincurve.egg-info
rm -rf libsecp256k1
rm -rf _cffi_build/*.h

if [[ "${PKG_NAME: -7}" == "-shared" ]]; then
  export SECP256K1_SHARED_LIBS="1"
else
  export SECP256K1_SHARED_LIBS="0"
fi

${PYTHON} ${RECIPE_DIR}/compose_cffi_files.py

${PYTHON} -m pip install --use-pep517 . -vvv
