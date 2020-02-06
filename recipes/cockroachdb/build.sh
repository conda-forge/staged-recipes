#!/usr/bin/env bash

set -ex

mkdir -p $PREFIX/bin

mv $SRC_DIR/cockroach $PREFIX/bin
