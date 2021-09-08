#!/usr/bin/env bash

autoreconf -vfi

./configure --prefix=$PREFIX

make

make install
