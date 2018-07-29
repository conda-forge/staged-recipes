#!/bin/bash -e

# build statically linked binary with Rust
cargo build --release
cargo install --root "$PREFIX"
