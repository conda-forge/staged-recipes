set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
cargo install --no-track --locked --root "%LIBRARY_PREFIX%" --path . || exit 1
