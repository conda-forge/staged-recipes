#!/bin/bash
cargo build --release --bin zyra
mkdir -p "$PREFIX/bin"
cp target/release/zyra "$PREFIX/bin/"
