@echo on

cd crates\uv

cargo install ^
    --locked ^
    --path . ^
    --profile release ^
    --root "%LIBRARY_PREFIX%" ^
    || exit 1

md "%LIBRARY_PREFIX%\bin" ^
    || echo "`%LIBRARY_PREFIX%\bin` already exists"

move "%PREFIX%\bin\uv.exe" "%LIBRARY_PREFIX%\bin\uv.exe" ^
    || exit 2

cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 3

del "%$PREFIX%\.crates2.json"
del "%$PREFIX%\.crates.toml"
