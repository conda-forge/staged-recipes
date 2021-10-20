#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi

ARCH=native ./configure -conda -nogui -verbose
./build -verbose
cp -r bin lib share $PREFIX
