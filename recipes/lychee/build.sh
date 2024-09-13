#!/usr/bin/env bash
set -eux

export OPENSSL_DIR=$PREFIX
export OPENSSL_NO_VENDOR=1
export CARGO_PROFILE_RELEASE_STRIP=debuginfo

cd lychee-bin

cargo install \
  --bins \
  --locked \
  --no-track \
  --path . \
  --profile release \
  --root "${PREFIX}"

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"
