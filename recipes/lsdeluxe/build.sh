cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release
mkdir -p $PREFIX/bin
mv target/*/release/lsd $PREFIX/bin/lsd
