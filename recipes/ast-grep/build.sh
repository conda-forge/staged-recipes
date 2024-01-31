#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo install --verbose --locked --root ${PREFIX} --path ./crates/cli --bin sg
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

${STRIP} ${PREFIX}/bin/sg
