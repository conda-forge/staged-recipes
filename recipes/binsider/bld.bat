@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error
:: https://github.com/orhun/binsider/blob/03bc7f53318195161294e164b74f4a7adb275fc1/.github/workflows/ci.yml#L97
cargo install --no-track --no-default-features --locked --root "%PREFIX%" --path . || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
