#!/bin/bash

set -ex

./configure --prefix=$PREFIX

make -j${CPU_COUNT}

make install
