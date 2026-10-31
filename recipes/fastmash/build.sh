#!/bin/bash
set -euxo pipefail
# Installs both programs; fastmash-sort-supervisor must sit beside fastmash.
cargo auditable install --locked --no-track --bins --root "$PREFIX" --path crates/cli
# The channel's license bundle plus the release's copyright and notice texts.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
python scripts/third_party_licenses.py > THIRD-PARTY-LICENSES.md
mkdir -p "$PREFIX/share/doc/fastmash"
for document in README.md LICENSE-MIT LICENSE-APACHE THIRD-PARTY-LICENSES.md THIRDPARTY.yml; do
    install -m644 "$document" "$PREFIX/share/doc/fastmash/$document"
done
