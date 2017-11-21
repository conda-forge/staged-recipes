#!/bin/bash

make config \
     shared=1 \
     prefix=$PREFIX

make
make install
