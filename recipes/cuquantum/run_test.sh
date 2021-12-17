#!/bin/bash
set -ex

test -f $PREFIX/include/custatevec.h
test -f $PREFIX/include/cutensornet.h
test -f $PREFIX/include/cutensornet/types.h
test -f $PREFIX/lib/libcustatevec.so
test -f $PREFIX/lib/libcutensornet.so

# TODO: add dlopen test
# TODO: add compiling test
