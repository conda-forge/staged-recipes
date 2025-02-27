set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cd .\crates\rattler_index
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
cargo install --no-track --locked --features native-tls --no-default-features --root "%LIBRARY_PREFIX%" --path . || exit 1
