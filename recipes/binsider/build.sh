#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if [[ "$target_platform" =~ ^osx.* ]]; then
    # https://github.com/orhun/binsider/blob/03bc7f53318195161294e164b74f4a7adb275fc1/.github/workflows/ci.yml#L103
    cargo install --no-default-features --no-track --locked --root "$PREFIX" --path .
else
    cargo install --no-track --locked --root "$PREFIX" --path .
fi
