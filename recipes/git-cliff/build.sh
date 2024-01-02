set -ex

cargo build --release
cargo install --path git-cliff --bins --root "${PREFIX}"
rm $PREFIX/.crates2.json
rm $PREFIX/.crates.toml
