@echo on

set OPENSSL_NO_VENDOR=1
set CARGO_PROFILE_RELEASE_STRIP=debuginfo

cd lychee-bin

cargo install ^
    --bins ^
    --locked ^
    --path . ^
    --profile release ^
    --root "%LIBRARY_PREFIX%" ^
    || exit 1

cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 2

del "%$PREFIX%\Library\.crates2.json"
del "%$PREFIX%\Library\.crates.toml"
