#!/bin/bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo build --release

# Install libraries
install -d "$PREFIX/lib"
install -m 644 target/release/libreadcon_core.a "$PREFIX/lib/"
install -m 755 target/release/libreadcon_core.so "$PREFIX/lib/"

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
