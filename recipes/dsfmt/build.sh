#!/usr/bin/env bash

make std
make std-check
make sse2-check

cp dSFMT.h ${PREFIX}/include
