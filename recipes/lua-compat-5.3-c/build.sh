#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/include/lua-compat-5.3
cp -r c-api ${PREFIX}/include/lua-compat-5.3
