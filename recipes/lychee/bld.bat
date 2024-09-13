@echo on

set OPENSSL_NO_VENDOR=1
set CARGO_PROFILE_RELEASE_STRIP=debuginfo
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

cd lychee-bin

cargo install ^
    --bins ^
    --locked ^
    --no-track ^
    --path . ^
    --profile release ^
    --root "%LIBRARY_PREFIX%" ^
    || exit 1

cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 2
