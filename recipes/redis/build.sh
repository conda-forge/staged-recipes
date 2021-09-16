#!/bin/bash

unset ARCH

echo "\#include <stdatomic.h>" > foo.c
$(CC) -std=c11 -c foo.c -o foo.o

if [ ! -f foo.o ]; then exit 1;

make
make install