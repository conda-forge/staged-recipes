#!/usr/bin/env bash

cd sources
sed -i 's/^gcc/$CC $CFLAGS $LDFLAGS/g' compile.sh
./compile.sh -fopenmp
cp sofia $PREFIX/bin
