set -ex
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release --locked
cargo install --path . --root $PREFIX --locked
rm $PREFIX/.crates2.json
rm $PREFIX/.crates.toml
