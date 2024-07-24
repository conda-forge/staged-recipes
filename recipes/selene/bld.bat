:: check licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml || goto :error

:: build statically linked binary with Rust
cargo install --no-target --locked --root %LIBRARY_PREFIX% --path selene || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
