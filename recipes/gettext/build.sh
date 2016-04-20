#!/usr/bin/env bash
./configure --prefix=$PREFIX
make
make check
make install
