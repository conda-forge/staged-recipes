cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export RUST_BACKTRACE=1
cargo build --release --locked


mkdir -p $PREFIX/bin/
mv ./target/*/release/meilisearch $PREFIX/bin/meilisearch
