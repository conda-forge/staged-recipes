#!/bin/bash -e

./configure --disable-codegen-tests --prefix=$PREFIX --llvm-root=$PREFIX
make
make install


# Download a precompiled version of cargo.
# This is needed to build cargo itself.
if [[ $OSTYPE == darwin* ]]
then
    CARGO_STAGE0=https://static.rust-lang.org/dist/cargo-$PKG_VERSION-x86_64-apple-darwin.tar.gz
else
    CARGO_STAGE0=https://static.rust-lang.org/dist/cargo-$PKG_VERSION-x86_64-unknown-linux-gnu.tar.gz
fi

curl $CARGO_STAGE0 | tar xz */cargo/bin/cargo --strip=2

cd cargo
./configure --prefix=$PREFIX --cargo=../bin/cargo --rustc=$PREFIX/bin/rustc --rustdoc=$PREFIX/bin/rustdoc
make
make install
