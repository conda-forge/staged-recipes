set -ex
export CARGO_PKG_VERSION=${PKG_VERSION}
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cp ${PREFIX}/include/webgpu.h ffi/webgpu.h

cargo build --release --all-features

rm target/CACHEDIR.TAG
rm -rf target/release
cp target/*/release/libwgpu_native${SHLIB_EXT} ${PREFIX}/lib/libwgpu_native${SHLIB_EXT}

mkdir -p ${PREFIX}/include

cp ffi/wgpu.h ${PREFIX}/include/wgpu.h
