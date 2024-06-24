cargo build --locked --profile release --package zenoh-plugin-storage-manager
mkdir -p ${PREFIX}/lib
cp ./target/${CARGO_BUILD_TARGET}/release/libzenoh_plugin_storage_manager${SHLIB_EXT} ${PREFIX}/lib/
