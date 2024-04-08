#!/bin/bash

set -ex

cargo fix --lib -p cargo-make --allow-no-vcs
cargo install --path . --root ${PREFIX} --locked
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
