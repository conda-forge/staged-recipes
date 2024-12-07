Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Use Conda Rust source libraries (compiled/tested) instead of downloading from crates.io
$EGUI_PHOSPHOR_VERSION = (Get-ChildItem "$env:BUILD_PREFIX/src/rust-libraries/egui-phosphor-rust-source-*" -Directory | ForEach-Object { $_.Name -match '\d+\.\d+\.\d+' | Out-Null; $Matches[0] } | Sort-Object -Version | Select-Object -Last 1)
$PREFERENCES_VERSION = (Get-ChildItem "$env:BUILD_PREFIX/src/rust-libraries/preferences-rs-rust-source-*" -Directory | ForEach-Object { $_.Name -match '\d+\.\d+\.\d+' | Out-Null; $Matches[0] } | Sort-Object -Version | Select-Object -Last 1)
$SERIALPORT_VERSION = (Get-ChildItem "$env:BUILD_PREFIX/src/rust-libraries/serialport-rs-rust-source-*" -Directory | ForEach-Object { $_.Name -match '\d+\.\d+\.\d+' | Out-Null; $Matches[0] } | Sort-Object -Version | Select-Object -Last 1)

New-Item -ItemType Directory -Force -Path .cargo
New-Item -ItemType File -Force -Path .cargo/config.toml
Add-Content -Path .cargo/config.toml -Value @"

[patch.crates-io]
serialport = { path = "$env:BUILD_PREFIX/src/rust-libraries/serialport-rs-rust-source-$SERIALPORT_VERSION" }
egui-phosphor = { path = "$env:BUILD_PREFIX/src/rust-libraries/egui-phosphor-rust-source-$EGUI_PHOSPHOR_VERSION" }
preferences = { path = "$env:BUILD_PREFIX/src/rust-libraries/preferences-rs-rust-source-$PREFERENCES_VERSION" }
"@

cargo build --release --all-targets
cargo test --release --all-targets
$env:CARGO_TARGET_DIR = "target"
cargo install --path . --root "$env:PREFIX"
cargo-bundle-licenses --format yaml --output "$env:RECIPE_DIR/THIRDPARTY.yml"