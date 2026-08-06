@echo on
setlocal EnableDelayedExpansion

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: Write third-party license inventory into the source tree (packaged via license_file).
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"
if errorlevel 1 exit /b 1

:: Public CLIs only (skip snapper-gen-docs). snapper-fmt aliases snapper.
cargo auditable install --locked --no-track --bin snapper --bin snapper-fmt --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit /b 1
