#!/usr/bin/env bash

set -x
set -e

make

cp bin/* "${PREFIX}/bin"
