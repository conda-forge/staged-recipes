#!/bin/bash
make

mkdir -p ${PREFIX}/bin
install tree ${PREFIX}/bin/tree

mkdir -p ${PREFIX}/man/man1
install doc/tree.1 ${PREFIX}/man/man1/tree.1

