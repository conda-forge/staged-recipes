#!/bin/bash
set -eu

### Create Makefiles
./configure --prefix ${PREFIX}

### Build
make

### Install
make install

### Test / Check ?
make check
