#!/usr/bin/env bash

export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS} -L$PREFIX/lib"

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

cargo install --locked --features dataframe,extra --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/nu"
