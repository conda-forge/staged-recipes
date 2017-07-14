#!/bin/bash -e

##### build rustc

./configure --disable-codegen-tests --prefix=$PREFIX --llvm-root=$PREFIX
make
make install


##### build cargo

cd cargo
# use stage0 from rustc build
STAGE0=$(echo ../build/*/stage0/bin)

PATH=$STAGE0:$PATH cargo install --root $PREFIX
