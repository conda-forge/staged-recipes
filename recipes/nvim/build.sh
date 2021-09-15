#!/bin/env/bash

export LIBTOOL=${BUILD_PREFIX}/bin/libtool
export LIBTOOLIZE=${BUILD_PREFIX}/bin/libtoolize

cmake .. CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$PREFIX
ninja

