:: check licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml || goto :error

:: build statically linked binary with Rust
cargo install --no-track --locked --root %LIBRARY_PREFIX% --path . || goto :error
mklink %LIBRARY_PREFIX%\bin\xhs %LIBRARY_PREFIX%\bin\xh || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
