#!/usr/bin/env bash

# tar zxf wgms3d-2.0.tar.gz ; cd wgms3d-2.0
./configure --with-arpack
make
make install
