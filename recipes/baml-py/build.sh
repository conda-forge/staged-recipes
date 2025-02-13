#!/bin/bash

set -euxo pipefail

$PYTHON -m pip install engine/language_client_python/


pushd engine/language_client_python
cargo-bundle-licenses --format yaml --output $SRC_DIR/THIRDPARTY.yml
popd

