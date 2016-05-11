#!/bin/bash

./bootstrap $PREFIX

make
make check
make install
