@echo on

cd crates\uv

cargo install ^
    --locked ^
    --path . ^
    --profile release ^
    --root "%PREFIX%" || exit 1

move "%PREFIX%\bin\uv.exe" "%PREFIX%\Scripts\uv.exe" || exit 1

cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" || exit 1
