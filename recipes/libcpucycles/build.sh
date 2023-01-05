#!/bin/bash

set -ex

echo $CC >> compilers-default

./configure --prefix=$PREFIX

make

make install
