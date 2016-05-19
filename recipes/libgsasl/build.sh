#!/usr/bin/env bash

./configure --with-gssapi-impl=mit --prefix=$PREFIX
make
make install
make check
