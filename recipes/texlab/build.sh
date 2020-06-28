#!/usr/bin/env bash
set -eux

cargo build --release

mkdir -p "${PREFIX}/bin"

cp target/release/${PKG_NAME} "${PREFIX}/bin"
