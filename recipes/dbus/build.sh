#!/bin/bash

./configure --prefix=$PREFIX --with-launchd-agent-dir=$PREFIX

make
make check
make install
