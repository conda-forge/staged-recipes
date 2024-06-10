#!/usr/bin/env bash

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

cargo install --no-track --locked --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/typstyle"
