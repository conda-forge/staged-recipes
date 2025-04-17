@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: Bundle licenses
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml" || exit 1

:: Build
python -m pip install . ^
    --no-deps --ignore-installed -vv --no-build-isolation --disable-pip-version-check
