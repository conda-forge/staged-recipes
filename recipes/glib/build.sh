#!/usr/bin/env bash
./configure --prefix="${PREFIX}" --with-python="${PYTHON}"
make
make check
make install


