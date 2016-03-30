#!/usr/bin/env bash

./autogen.sh
make
make check
make install
