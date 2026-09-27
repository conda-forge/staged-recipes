set CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"

cargo auditable install --locked --no-track --path . --root %LIBRARY_PREFIX%
