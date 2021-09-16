#!/bin/bash

echo "#include <stdatomic.h>" > foo.c
x86_64-apple-darwin13.4.0-clang -std=c11 -c foo.c -o foo.o

ls foo*

exit 1