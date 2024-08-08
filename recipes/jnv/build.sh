#!/usr/bin/env bash

export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS} -L$PREFIX/lib"

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

# TODO: add --locked
cargo install --no-track --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/jnv"
