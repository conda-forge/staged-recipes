#!/bin/bash
tar xf ghc-8.2.1-x86_64-deb7-linux.tar.xz
cd ghc-8.2.1
./configure --prefix={$PREFIX}
make install
