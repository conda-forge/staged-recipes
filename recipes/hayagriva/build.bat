:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

set CARGO_PROFILE_RELEASE_LTO=fat

:: build
cargo install --features cli --locked --root "%PREFIX%" --path . --no-track || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1