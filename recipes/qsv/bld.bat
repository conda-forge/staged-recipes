:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: get latest rust stable
rustup update

:: build
cargo install --root "%LIBRARY_PREFIX%" --path . --all-features || goto :error

:: remove extra build file
del /F /Q "%LIBRARY_PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
