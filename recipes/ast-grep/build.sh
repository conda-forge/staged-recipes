#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo install --verbose --locked --root ${PREFIX} --path ./crates/cli --bin ast-grep
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

${STRIP} ${PREFIX}/bin/ast-grep
ln -s ${PREFIX}/bin/ast-grep ${PREFIX}/bin/sg
