#!/usr/bin/env bash

if [[ "${build_platform}" == linux-* ]]; then
    export OPENSSL_DIR=$PREFIX
fi

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

cargo install --no-track --locked --root "$PREFIX" --path .

"$STRIP" "$PREFIX/bin/typst-lsp"
