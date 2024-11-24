set CARGO_PROFILE_RELEASE_STRIP=symbols || goto :error
set CARGO_PROFILE_RELEASE_LTO=fat || goto :error

:: check licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml || goto :error

:: build statically linked binary with Rust
cargo install --bins --no-track --locked --root ${PREFIX} --path . || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
