#!/bin/bash

set -ex

# generate configuration scripts
./autogen.sh

# configure
./configure --prefix=$PREFIX

# compile
make

# check that this worked
make check

# install
make install
