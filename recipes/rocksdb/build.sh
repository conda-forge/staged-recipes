#!/bin/bash

### Build
export INSTALL_PATH=${PREFIX}
make release
make shared_lib

### Install
make install
