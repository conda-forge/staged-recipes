@echo off
setlocal enabledelayedexpansion

cargo build --release --all-targets
cargo test --release --lib

rem This is a Rust source distribution, we need to remove the target directory
rd /s /q target

rem Install source distribution
mkdir %PREFIX%\src\rust-libraries\%PKG_NAME%-%PKG_VERSION%
xcopy /e /i . %PREFIX%\src\rust-libraries\%PKG_NAME%-%PKG_VERSION%

rem Adding the checksums of the source distribution to the recipe
(
echo {"files":{},"package":"%PKG_SHA256%"}
) > %PREFIX%\src\rust-libraries\%PKG_NAME%-%PKG_VERSION%\.cargo-checksum.json

cargo-bundle-licenses --format yaml --output "%RECIPE_DIR%\THIRDPARTY.yml"