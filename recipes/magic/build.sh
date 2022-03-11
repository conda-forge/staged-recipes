#!/bin/bash
set -ex

./configure --prefix="${PREFIX}"
make V=1
make V=1 install

