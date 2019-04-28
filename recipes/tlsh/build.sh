#!/usr/bin/env bash
sh make.sh
cd build/release
make install
cp ../../bin/* ${PREFIX}/bin
