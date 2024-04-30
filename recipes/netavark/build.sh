#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# build
cargo install --locked \
    --root "$PREFIX/lib/podman" \
    --path .

mv $PREFIX/lib/podman/bin/* $PREFIX/lib/podman/
rmdir $PREFIX/lib/podman/bin

# strip debug symbols
"$STRIP" "$PREFIX/lib/podman/netavark"
"$STRIP" "$PREFIX/lib/podman/netavark-dhcp-proxy-client"

cargo-bundle-licenses \
    --format yaml \
    --output "${SRC_DIR}/THIRDPARTY.yml"

# remove extra build files
rm -f "${PREFIX}/.crates2.json" "${PREFIX}/.crates.toml"
