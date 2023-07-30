cargo build --release --all-features

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

rm target/CACHEDIR.TAG
rm -rf target/release
cp target/*/release/libwgpu_native${SHLIB_EXT} ${PREFIX}/lib/libwgpu_native${SHLIB_EXT}
