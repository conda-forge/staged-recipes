#! /bin/bash

set -e

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    rustc_args=(
        -C link-args="-Wl,-rpath,$PREFIX/lib"
    )
else
    rustc_args=(
        -C link-args="-Wl,-rpath-link,$PREFIX/lib"
    )
fi

cargo build --release --lib --verbose
cargo rustc --bin tectonic --release -- "${rustc_args[@]}"
cargo install --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
