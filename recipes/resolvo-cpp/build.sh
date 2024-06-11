#!/bin/bash

set -euxo pipefail

cmake ${CMAKE_ARGS} -GNinja $SRC_DIR -DRust_CARGO_TARGET=${CARGO_BUILD_TARGET}
ninja install

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
