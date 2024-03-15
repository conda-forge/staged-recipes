#!/usr/bin/env bash

export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS} -L$PREFIX/lib"

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

# TODO: add --locked on next release
cargo install --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/lucky_commit"
