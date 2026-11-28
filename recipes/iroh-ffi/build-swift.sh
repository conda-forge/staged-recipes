#!/usr/bin/env bash

set -euxo pipefail

export MACOSX_DEPLOYMENT_TARGET="14.5"
UDL_NAME="iroh_ffi"

# Find the compiled native library from iroh-ffi-python installed as a HOST dep.
# On macOS (the only platform this script runs on), maturin produces a .dylib.
IROH_LIB=$(find "${PREFIX}" -name "libiroh_ffi.dylib" | head -1)

# Generate Swift bindings against the compiled library
mkdir -p ./include/apple
uniffi-bindgen generate --language swift \
  --out-dir ./include/apple \
  --library "$IROH_LIB"

# Rename Swift interface (iroh_ffi - IrohLib)
sed 's/iroh_ffi/IrohLib/g' "include/apple/${UDL_NAME}.swift" \
  > IrohLib/Sources/IrohLib/IrohLib.swift

# Populate macos-arm64 framework slice
mkdir -p Iroh.xcframework/macos-arm64/Iroh.framework/Headers
mkdir -p Iroh.xcframework/macos-arm64/Iroh.framework/Modules

cp "include/apple/${UDL_NAME}FFI.h" \
  Iroh.xcframework/macos-arm64/Iroh.framework/Headers/
cp "include/apple/${UDL_NAME}FFI.modulemap" \
  Iroh.xcframework/macos-arm64/Iroh.framework/Modules/module.modulemap

# Copy native lib and fix install name for macOS framework
cp "$IROH_LIB" Iroh.xcframework/macos-arm64/Iroh.framework/Iroh
install_name_tool -id "@rpath/Iroh.framework/Iroh" \
  Iroh.xcframework/macos-arm64/Iroh.framework/Iroh

# Rewrite Info.plist — macOS-only (drop iOS slices)
cat > Iroh.xcframework/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>LibraryIdentifier</key>
			<string>macos-arm64</string>
			<key>LibraryPath</key>
			<string>Iroh.framework</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>macos</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
PLIST

mkdir -p "$PREFIX/lib"
cp -r Iroh.xcframework "$PREFIX/lib/"
cp -r IrohLib "$PREFIX/lib/"
