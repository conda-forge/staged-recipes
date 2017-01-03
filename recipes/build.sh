#!/bin/bash
./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            $OPTS


make
make check
make install
