#!/bin/sh
make CC=${CC} all
mv include/* ${PREFIX}/include/
mv lib/* ${PREFIX}/lib/
