@echo on

:: build
cargo install --locked ^
    --root "%PREFIX%" ^
    --path . ^
    || exit 1

:: strip debug symbols
strip "%PREFIX%\bin\cargo-llvm-cov.exe" || exit 1

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

:: remove extra build files
del /F /Q "%PREFIX%\.crates.toml"
del /F /Q "%PREFIX%\.crates2.json"
