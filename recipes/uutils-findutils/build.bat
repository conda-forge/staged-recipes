@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat
set RUSTONIG_DYNAMIC_LIBONIG=1

cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY.yml

:: build statically linked binary with Rust
cargo install --bins --no-track --locked --root %LIBRARY_PREFIX% --path .
