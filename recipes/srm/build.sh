#!/bin/bash

./configure --prefix="${PREFIX}"
make
make test
make install
