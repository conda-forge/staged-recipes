#!/usr/bin/env bash

# webauthn-authenticator-rs needs to use openssl at build time.
# This helps it find it.
export DYLD_FALLBACK_LIBRARY_PATH="$BUILD_PREFIX/lib"

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY_LICENSES.yaml

cargo install --locked --root "$PREFIX" --path tools/cli

"$STRIP" "$PREFIX/bin/kanidm"
