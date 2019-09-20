#!/usr/bin/env bash
set -ex

export prefix="$PREFIX"
make
make install
