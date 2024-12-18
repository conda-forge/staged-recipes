#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

pushd frontend
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=../THIRDPARTY-frontend.yml
popd

export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${PREFIX}/lib -L${PREFIX}/lib"

if [[ "$target_platform" == linux* ]]
then
    cargo install --no-track --locked --features unwind --root "$PREFIX" --path .
else
    cargo install --no-track --locked --root "$PREFIX" --path .
fi
