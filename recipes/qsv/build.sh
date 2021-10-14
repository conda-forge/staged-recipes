#!/bin/bash
cargo build --release
cargo install --bin qsv --root $PREFIX
