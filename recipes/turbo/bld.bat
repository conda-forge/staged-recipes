:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

:: build
set RUSTC_BOOTSTRAP=1
cargo install --bins --no-track --locked --root "%LIBRARY_PREFIX%" --path crates/turborepo || goto :error

:EOF

:error
echo Failed with error #%errorlevel%.
exit 1
