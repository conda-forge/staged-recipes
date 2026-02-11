set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo install --no-track --locked --root "%PREFIX%" --path crates/fresh-editor
if errorlevel 1 exit 1
