#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# crates/workspace/build.rs embeds these archives; it exits 1 with an explanatory
# message if they are missing, but check here so a source layout change reads as a
# recipe problem rather than a compile failure.
ls -1 "${SRC_DIR}"/.cache/sysml-stdlib-kpar-*/*.kpar > /dev/null
ls -1 "${SRC_DIR}"/.cache/*.kpar > /dev/null

# rust-toolchain.toml pins an exact channel for upstream CI. It is a rustup feature and
# is ignored by the bare cargo/rustc that the conda-forge rust compiler provides, so the
# packaged toolchain is used regardless. Removed anyway to keep that explicit.
rm -f rust-toolchain.toml

export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# Two binaries from two workspace members: `spec42` from crates/server (the language
# server and CLI, which is the only artifact upstream publishes) and `kpar-pack` from
# crates/kpar. Both installs share the workspace target directory, so the second reuses
# the first's dependency build.
cargo install --locked --no-track --root "${PREFIX}" --path crates/server
cargo install --locked --no-track --root "${PREFIX}" --path crates/kpar
