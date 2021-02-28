#!/bin/bash

sed -i.bak 's/^BINDIR.*//g' Makefile

# Build
make clean
make

# Test
make lite-test

# Install
DESTDIR=${PREFIX} BINDIR=/bin/ make install

