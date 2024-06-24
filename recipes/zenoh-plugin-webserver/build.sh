cargo build --locked --profile release
mkdir -p ${PREFIX}/lib
cp ./target/${CARGO_BUILD_TARGET}/release/libzenoh_plugin_webserver${SHLIB_EXT} ${PREFIX}/lib/

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml
