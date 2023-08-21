#!/bin/bash

set -eox pipefail

rm -rf ${SRC_DIR}/{coincurve.egg-info, libsecp256k1}

${PYTHON} -m pip install --use-pep517 . -vvv .
