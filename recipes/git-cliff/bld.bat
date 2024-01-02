echo ON

cargo build --release
cargo install --path git-cliff --bins --root %PREFIX%
del %PREFIX%\.crates2.json
del %PREFIX%\.crates.toml
