#!/bin/bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release

# conda-forge rust-activation sets CARGO_BUILD_TARGET, which places
# output under target/<triple>/release/ instead of target/release/
if [ -n "${CARGO_BUILD_TARGET:-}" ]; then
    RELEASE_DIR="target/${CARGO_BUILD_TARGET}/release"
else
    RELEASE_DIR="target/release"
fi

# Install static library
install -d "$PREFIX/lib"
install -m 644 "${RELEASE_DIR}/libreadcon_core.a" "$PREFIX/lib/"

# Install shared library (platform-dependent extension)
if [ "$(uname)" = "Darwin" ]; then
    install -m 755 "${RELEASE_DIR}/libreadcon_core.dylib" "$PREFIX/lib/"
else
    install -m 755 "${RELEASE_DIR}/libreadcon_core.so" "$PREFIX/lib/"
fi

# Install pre-generated headers
install -d "$PREFIX/include"
install -m 644 include/readcon-core.h "$PREFIX/include/"
install -m 644 include/readcon-core.hpp "$PREFIX/include/"

# Generate pkgconfig
install -d "$PREFIX/lib/pkgconfig"
cat > "$PREFIX/lib/pkgconfig/readcon-core.pc" << PCEOF
prefix=\${pcfiledir}/../..
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: readcon-core
Description: CON file reader/writer in Rust with C FFI bindings
Version: ${PKG_VERSION}
Libs: -L\${libdir} -lreadcon_core
Cflags: -I\${includedir}
PCEOF
