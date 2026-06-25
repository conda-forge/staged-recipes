@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols

cargo install --no-track --locked --root "%PREFIX%" --path csv-utils || exit 1
cargo install --no-track --locked --root "%PREFIX%" --path csv-utils-web || exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1

del /q "%PREFIX%\.crates.toml" 2>nul
del /q "%PREFIX%\.crates2.json" 2>nul
