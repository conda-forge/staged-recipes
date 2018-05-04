#!/usr/bin/env bash
set -ex
rustc -V
cargo -V

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"
fi

cargo build --release --verbose
cargo install --bin $PKG_NAME --root $PREFIX
rm -f $PREFIX/.crates.toml
