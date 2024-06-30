cargo build --locked --profile release --package zenoh-plugin-rest
mkdir -p ${PREFIX}/lib
cp ./target/${CARGO_BUILD_TARGET}/release/libzenoh_plugin_rest${SHLIB_EXT} ${PREFIX}/lib/
