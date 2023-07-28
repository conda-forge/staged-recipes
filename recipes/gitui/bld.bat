echo ON
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
cargo build --release
if errorlevel 1 exit 1
cargo install --path . --root %LIBRARY_PREFIX%
