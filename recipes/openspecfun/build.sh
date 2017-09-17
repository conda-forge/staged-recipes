#!/usr/bin/env bash

make prefix="${PREFIX}/" USE_OPENLIBM=1
make install prefix="${PREFIX}/"
