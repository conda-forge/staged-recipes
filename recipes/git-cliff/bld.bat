echo ON

cargo-bundle-licenses --format yaml --output %SRC_DIR%/THIRDPARTY.yml
cargo install --path git-cliff --bins --root %PREFIX% --locked

del %PREFIX%\.crates2.json
del %PREFIX%\.crates.toml
