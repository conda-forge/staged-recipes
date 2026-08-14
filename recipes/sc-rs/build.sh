#!/usr/bin/env bash
set -euo pipefail

export CARGO_HOME="${SRC_DIR}/.cargo"

# Determine Rust target triple (important on osx-arm64)
RUST_TARGET="${CARGO_BUILD_TARGET:-}"
if [[ -z "${RUST_TARGET}" ]]; then
  case "${target_platform:-}" in
    osx-arm64) RUST_TARGET="aarch64-apple-darwin" ;;
    osx-64)    RUST_TARGET="x86_64-apple-darwin" ;;
    *)         RUST_TARGET="" ;;
  esac
fi

if [[ -n "${RUST_TARGET}" ]]; then
  cargo build --release --bin sc --target "${RUST_TARGET}"
  BIN="${SRC_DIR}/target/${RUST_TARGET}/release/sc"
else
  cargo build --release --bin sc
  BIN="${SRC_DIR}/target/release/sc"
fi

install -m 755 -d "${PREFIX}/bin"
install -m 755 "${BIN}" "${PREFIX}/bin/sc"
