:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: build
cargo install --locked --root "%PREFIX%" --path cargo-insta --no-track || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
