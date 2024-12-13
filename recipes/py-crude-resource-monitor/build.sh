#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

pushd frontend
pnpm-licenses generate-disclaimer --prod --output-file=../THIRDPARTY-frontend.yml
popd

cargo install --no-track --locked --root "$PREFIX" --path .
