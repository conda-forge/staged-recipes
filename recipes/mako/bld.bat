set RUSTC_BOOTSTRAP=1
:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

:: build
cargo install --bins --no-track --locked --root "%LIBRARY_PREFIX%" --path crates/mako || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
