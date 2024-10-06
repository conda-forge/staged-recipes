cd compiler || goto :error

:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

:: build
cargo install --bins --no-track --locked --root "%LIBRARY_PREFIX%" --path crates\relay-bin || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
