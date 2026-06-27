set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo install --locked --no-track --bin snapper --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit 1
