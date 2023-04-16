@echo on

:: build
cargo install --locked ^
    --root "%PREFIX%" ^
    --path crates/taplo-cli ^
    --features lsp,rustls-tls ^
    || exit 1

:: strip debug symbols
strip "%PREFIX%\bin\taplo.exe" || exit 1

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

:: remove extra build file
del /F /Q "%PREFIX%\.crates.toml"
