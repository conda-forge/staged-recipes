@echo on

cd crates\uv

cargo install ^
    --locked ^
    --path . ^
    --profile release ^
    --root "%LIBRARY_PREFIX%" ^
    || exit 1


cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 3

del "%$PREFIX%\.crates2.json"
del "%$PREFIX%\.crates.toml"
