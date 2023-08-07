echo ON
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
cargo build --release --locked
if errorlevel 1 exit 1
cargo install --path . --root %PREFIX% --locked
