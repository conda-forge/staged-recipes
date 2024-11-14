#!/usr/bin/env bash

set -euxo pipefail

cargo install --locked --root "${PREFIX}" yazi-fm yazi-cli

rm "$PREFIX/.crates2.json"
rm "$PREFIX/.crates.toml"
