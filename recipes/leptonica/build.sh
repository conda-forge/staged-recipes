#!/usr/bin/env bash

./autobuild
CFLAGS=-O2 ./configure --prefix=$PREFIX
make
make install
