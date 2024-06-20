#!/bin/bash
set -ex

cd src/simplification/rdp

# Bundle all downstream library licenses
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY_LICENSES.yaml

# Copy the built library and header to the root of the source directory
case ${target_platform} in                                  
  linux-64)
  	TARGET=x86_64-unknown-linux-gnu
	cargo build --release --target=${TARGET} --features headers
    cp target/${TARGET}/release/librdp.so ../
    ;;                               
  linux-aarch64)
  	TARGET=aarch64-unknown-linux-gnu
	cargo build --release --target=${TARGET} --features headers
    cp target/${TARGET}/release/librdp.so ../
    ;;
  osx-64)
  	TARGET=x86_64-apple-darwin
	export MACOSX_DEPLOYMENT_TARGET=10.9
	cargo build --release --target=${TARGET} --features headers
	for lib in target/${TARGET}/release/*.dylib; do
		install_name_tool -id "@rpath/librdp.dylib" $lib
		otool -L $lib
	done
    cp target/${TARGET}/release/librdp.dylib ../
    ;;
  osx-arm64)
	xcodebuild -showsdks
	SDKROOT=$(xcrun -sdk macosx14.0 --show-sdk-path)
  	TARGET=aarch64-apple-darwin
	export MACOSX_DEPLOYMENT_TARGET=11.0
	cargo build --release --target=${TARGET} --features headers
	for lib in target/${TARGET}/release/*.dylib; do
		install_name_tool -id "@rpath/librdp.dylib" $lib
		otool -L $lib
	done
    cp target/${TARGET}/release/librdp.dylib ../
    ;;
  *)
    echo "Unsupported platform: ${target_platform}"
	exit 1
	;;
esac

cp include/header.h ../

cd ${SRC_DIR}

# Build the Python package
$PYTHON -m pip install . -vv --no-deps --no-build-isolation || exit 1
