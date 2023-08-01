set -ex
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release
cargo install --path . --root $PREFIX
