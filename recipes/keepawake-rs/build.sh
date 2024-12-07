#!/usr/bin/env bash

set -euxo pipefail

cargo build --release --all-targets
# Skip doc-test which fails to find cc as a linker (odd, since it can build just fine)
cargo test --release --all-targets
CARGO_TARGET_DIR=target cargo install --features="bin" --path . --root "${PREFIX}"
cargo-bundle-licenses --format yaml --output "${RECIPE_DIR}"/THIRDPARTY.yml
