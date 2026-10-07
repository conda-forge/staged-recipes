@echo on
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit /b 1
cargo install --locked --no-track --root "%LIBRARY_PREFIX%" --path . || exit /b 1