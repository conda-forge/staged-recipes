#!/bin/bash

set -ex

[[ -d lib64 ]] && mv lib64 lib

check-glibc bin/*

cp -rv bin $PREFIX/
