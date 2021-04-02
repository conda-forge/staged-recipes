#! /bin/bash

export FFLAGS="-Wall -Wextra -Wpedantic -std=f2003 -Wimplicit-interface $FFLAGS"

$FC $FFLAGS src/*Component.f03 src/*CLI.f03 src/Main.f03 -o simplecrop

install simplecrop ${PREFIX}/bin
