echo ON
cargo install --path git-cliff --bins --root %PREFIX% --locked
del %PREFIX%\.crates2.json
del %PREFIX%\.crates.toml
