#!/usr/bin/env sh

cargo bundle-licenses --format yaml --output DENO_THIRDPARTY_LICENSES.yml
cargo install deno --locked --root $PREFIX
