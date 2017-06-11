#!/bin/bash

cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX

make
make install
