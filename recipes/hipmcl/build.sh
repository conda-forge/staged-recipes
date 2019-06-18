#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BINARY_DIR=$PREFIX ..
make
chmod +x ./bin/hipmcl
cp ./bin/hipmcl ${PREFIX}/bin/hipmcl
cd ..


# Copy examples
TMP="$PREFIX/share/$PKG_NAME-$PKG_VERSION"
mkdir -p "$TMP"
cp -R test/* $TMP
cp -R data $TMP
