set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: check licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml || goto :error

:: build statically linked binary with Rust
set RUSTONIG_DYNAMIC_LIBONIG=1
set RUSTONIG_SYSTEM_LIBONIG=1
set LIBCLANG_PATH=%LIBRARY_PREFIX%\lib
cargo install --bins --features oniguruma --no-track --locked --root %LIBRARY_PREFIX% --path . || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
