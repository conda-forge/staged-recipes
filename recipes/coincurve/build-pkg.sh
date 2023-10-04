#!/bin/bash

set -eox pipefail

if [[ "${PKG_NAME: -7}" == "-shared" ]]; then
  export SECP256K1_SHARED_LIBS="1"
else
  export SECP256K1_SHARED_LIBS="0"
fi

${PYTHON} -m pip install . --no-build-isolation \
    --no-deps --ignore-installed --no-index --no-cache-dir -vvv --use-pep517
