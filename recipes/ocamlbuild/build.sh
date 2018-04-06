#!/bin/bash
make -f configure.make
make configure
make all
# This needs ocamlfind:
# make tests
make install
