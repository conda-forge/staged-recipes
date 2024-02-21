set -ex

cargo install --path git-cliff --bins --root "${PREFIX}" --locked

rm $PREFIX/.crates2.json
rm $PREFIX/.crates.toml
