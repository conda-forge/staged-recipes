#!/bin/bash
make -f configure.make
make configure
LINKFLAGS="" make all
# This needs ocamlfind:
# make tests
make install
