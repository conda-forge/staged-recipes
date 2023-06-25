set -ex

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo build --release
cargo install --path . --root "${PREFIX}"

# https://github.com/xiph/rav1e
cargo install cargo-c

# Hmm, does conda-forge have cargo-c??
# https://github.com/Homebrew/homebrew-core/blob/7d7fc5432ee7b16e7a7ce9f85951052f7ad55e96/Formula/rav1e.rb
cargo cinstall --library-type cdylib --release --prefix "${PREFIX}"
cargo uninstall cargo-c
