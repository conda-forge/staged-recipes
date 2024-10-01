:: check licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml || goto :error

:: build statically linked binary with Rust
cargo install --no-track --locked --root %LIBRARY_PREFIX% --path . || goto :error

mv %LIBRARY_PREFIX%\bin\fx.exe %LIBRARY_PREFIX%\bin\felix.exe || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
