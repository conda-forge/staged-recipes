@echo off
setlocal enabledelayedexpansion
set CARGO_TARGET_DIR=target

cargo build --release --all-targets
cargo test --release --all-targets
cargo install --path . --root "%PREFIX%"
cargo-bundle-licenses --format yaml --output "%RECIPE_DIR%\THIRDPARTY.yml"
endlocal
