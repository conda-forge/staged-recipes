#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --root "$PREFIX" --path .

# strip debug symbols
"$STRIP" "$PREFIX/bin/ssubmit"
