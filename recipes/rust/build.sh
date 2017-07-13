#!/bin/bash -e

##### build rustc

./configure --disable-codegen-tests --prefix=$PREFIX --llvm-root=$PREFIX
make
make install


##### build cargo

cd cargo
# use stage0 from rustc build
STAGE0=../build/*/stage0/bin

./configure --prefix=$PREFIX --cargo=$STAGE0/cargo --rustc=$STAGE0/rustc --rustdoc=$STAGE0/rustdoc
make
make install
