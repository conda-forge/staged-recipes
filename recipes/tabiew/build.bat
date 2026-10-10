@echo on
set OPENSSL_NO_VENDOR=1
set OPENSSL_DIR=%LIBRARY_PREFIX%
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit /b 1
cargo install --locked --no-track --root "%LIBRARY_PREFIX%" --path . || exit /b 1