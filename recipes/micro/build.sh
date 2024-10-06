#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make build-tags
go-licenses save ./cmd/micro --save_path=license-files

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/man/man1
install -m 755 micro ${PREFIX}/bin/micro
install -m 644 assets/packaging/micro.1 ${PREFIX}/share/man/man1/micro.1
