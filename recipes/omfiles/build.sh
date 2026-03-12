#!/bin/bash

set -euxo pipefail

# open-meteo/python-omfiles/issues/113
export CFLAGS="$CFLAGS -msse4.1"

$PYTHON -m pip install . --no-deps --no-build-isolation -vv
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
