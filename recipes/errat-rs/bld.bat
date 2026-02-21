@echo on
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --path . --root "%LIBRARY_PREFIX%" --bins

del /f /q "%LIBRARY_PREFIX%\.crates.toml"
del /f /q "%LIBRARY_PREFIX%\.crates2.json"
