#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi

CONDAFORGE=1 ./configure -verbose -nogui
./build -verbose
cp -r bin lib share "$PREFIX"

