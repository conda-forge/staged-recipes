#!/bin/bash

set -euxo pipefail

$PYTHON -m pip install . -vv
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
