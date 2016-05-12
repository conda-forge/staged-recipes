#!/usr/bin/env bash

src_dir="$(pwd)"
mkdir ../build
cd ../build
cmake $src_dir -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
