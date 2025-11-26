#!/bin/bash

cargo auditable build --release --package macos-certificate-truster \
    --target "$CARGO_BUILD_TARGET"
lipo -create -output target/release/macos-certificate-truster \
    "target/$CARGO_BUILD_TARGET/release/macos-certificate-truster"

(
  export LD="${CC_FOR_BUILD}" && \
  cd mitmproxy-macos/redirector && \
  mkdir build && mkdir dist && \
  # 1. Create an unsigned .xcarchive
  xcodebuild \
    -scheme macos-redirector \
    -archivePath build/macos-redirector.xcarchive \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGN_IDENTITY="" \
    archive && \
  # 2. Copy the .app out of the .xcarchive (the .xcarchive is just a folder)
  cp -R \
    build/macos-redirector.xcarchive/Products/Applications/"Mitmproxy Redirector.app" \
    "build/Mitmproxy Redirector.app" && \
  # 3. Create the .app.tar bundle in dist
  tar --create \
    --file "dist/Mitmproxy Redirector.app.tar" \
    --cd build \
    "Mitmproxy Redirector.app"
  rm -rf build
)

$PYTHON -m pip install ./mitmproxy-macos
cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml
