#!/bin/bash
cargo build --release
cargo install --bin xsv --root $PREFIX
