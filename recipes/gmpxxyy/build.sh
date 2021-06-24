#!/usr/bin/env bash
./configure --prefix="$PREFIX" --without-pytest --without-sage || (cat config.log; false)
make install
