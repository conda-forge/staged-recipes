cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml || goto :error

:: build statically linked binary with Rust
set SODIUM_USE_PKG_CONFIG=1 || goto :error
cargo install --bins --no-track --locked --root %LIBRARY_PREFIX% --path crates\kr || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
