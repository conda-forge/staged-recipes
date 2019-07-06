#!/usr/bin/env bash

./configure --prefix=${PREFIX} --disable-udev
make
make install
