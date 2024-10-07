#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make smemcap

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man8
install -m 755 smem  ${PREFIX}/bin
install -m 755 smemcap ${PREFIX}/bin
install -m 644 smem.8 ${PREFIX}/share/man/man8
