@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml" || exit 1

cargo install --locked --no-track --bin fast --root "%PREFIX%" --path . || exit 1
