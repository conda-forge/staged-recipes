#!/usr/bin/env bash
./configure --prefix="$PREFIX" --without-pytest || (cat config.log; false)
make install
