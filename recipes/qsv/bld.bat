:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: build
cargo install --root "$PREFIX" --path . --locked --features feature_capable,apply,generate,foreach,fetch,geocode || goto :error

:: remove extra build file
del /F /Q "%LIBRARY_PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
