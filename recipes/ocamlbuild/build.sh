#!/bin/bash
make -f configure.make
make configure
LINKFLAGS="" make native man
# This needs ocamlfind:
# make tests
make install-bin-native install-lib-native install-man
