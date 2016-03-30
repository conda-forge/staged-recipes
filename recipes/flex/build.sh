#!/bin/bash

./configure --prefix="$PREFIX"
make
# Skipped as this requires bison.
# Bison requires flex to build.
# So, will have to do the first
#  round of builds without this.
#make check
make install
