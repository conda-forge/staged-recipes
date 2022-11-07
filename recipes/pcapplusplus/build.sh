#!/bin/bash

./configure-linux.sh --default --install-dir $PREFIX
make -j${CPU_COUNT} libs
make install
