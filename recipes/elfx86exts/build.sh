#! /bin/bash

set -e
cargo install --bin elfx86exts --root $PREFIX
rm -f $PREFIX/.crates.toml
