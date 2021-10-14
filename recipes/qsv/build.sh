#!/bin/bash
cargo build --release
cargo install --path . --bin qsv --root $PREFIX
