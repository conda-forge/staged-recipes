#!/bin/bash

mkdir -p ./build
cd ./build
meson --prefix $PREFIX ..
ninja
#python3 -m pytest test/
ninja install
chown root:root util/fusermount3
chmod 4755 util/fusermount3
