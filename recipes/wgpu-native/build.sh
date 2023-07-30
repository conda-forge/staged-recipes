set -ex
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo build --release --all-features

rm target/CACHEDIR.TAG
rm -rf target/release
cp target/*/release/libwgpu_native${SHLIB_EXT} ${PREFIX}/lib/libwgpu_native${SHLIB_EXT}
