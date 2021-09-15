#!/bin/env/bash

export LIBTOOL=${BUILD_PREFIX}/bin/libtool
export LIBTOOLIZE=${BUILD_PREFIX}/bin/libtoolize

cmake .. -DUSE_BUNDLED=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
ninja

