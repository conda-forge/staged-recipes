#!/usr/bin/env bash
set -eux

cd crates/uv

cargo install \
  --locked \
  --path . \
  --profile release \
  --root "$PREFIX"

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"
