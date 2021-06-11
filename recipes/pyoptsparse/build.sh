#!/bin/bash

set -euo pipefail

cd ${SRC_DIR}
IPOPT_DIR=${PREFIX} ${PYTHON} -m pip install . -vv
