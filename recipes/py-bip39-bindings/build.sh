#!/bin/bash

set -x -e
set -o pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

${PYTHON} -m pip install . -vv
