#!/usr/bin/env bash

cd source
./prepare
make
make check
make install
