cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release --locked

mkdir -p $PREFIX/bin/
mv ./target/*/release/meilisearch $PREFIX/bin/meilisearch
