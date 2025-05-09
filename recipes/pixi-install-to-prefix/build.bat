set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

@REM hack: path too long for pixi_config subpackage, https://github.com/prefix-dev/pixi/issues/3691
set CARGO_HOME=C:\.cargo

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
cargo install --no-track --locked --root "%LIBRARY_PREFIX%" --path . || exit 1
