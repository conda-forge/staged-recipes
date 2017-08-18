#!/usr/bin/env bash

./configure --prefix=$PREFIX

make -j4
make install -j4

