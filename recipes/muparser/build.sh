#!/bin/sh

sh ./configure --prefix=$PREFIX
make lib
make
make install
DYLD_LIBRARY_PATH=lib LD_LIBRARY_PATH=lib ./samples/example1/example1
