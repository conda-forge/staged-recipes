#!/usr/bin/env bash
set -euo pipefail

# The OBS archive supplies vendor/ and Cargo's source replacement config.
mv obs/vendor .
mv obs/.cargo/config.toml .cargo/
export CARGO_NET_OFFLINE=true
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if [[ "$target_platform" == linux-* ]]; then
    # The native eBPF skeleton generator and the final binary both link libelf and zlib.
    unset CARGO_BUILD_TARGET
    export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS:-} -L native=$PREFIX/lib"
else
    # Link the SDK libpcap for Apple's PKTAP process metadata.
    export LIBPCAP_NO_PKG_CONFIG=1
fi
cargo install --path . --bin rustnet --root "$PREFIX" --locked --offline --no-track
