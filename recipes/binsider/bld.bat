@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error
cargo install --no-track --locked --root "%PREFIX%" --path . || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
