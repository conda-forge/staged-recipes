#!/usr/bin/env bash

CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib ./configure --prefix=$PREFIX

make
make check
make install