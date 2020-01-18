#!/bin/bash

./configure --prefix=${PREFIX} --enable-static --enable-shared
make
make check
make install
