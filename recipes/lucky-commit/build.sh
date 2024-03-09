#!/usr/bin/env bash

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

# TODO: add --locked on next release
cargo install --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/lucky_commit"
