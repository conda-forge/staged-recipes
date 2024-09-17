#!/usr/bin/env bash

set -exuo pipefail

mkdir -p "${PREFIX}/bin"
make -f Makefile

cp ./out/skaffold ${PREFIX}/bin/

# Clear out cache to avoid file not removable warnings
chmod -R u+w $(go env GOPATH) && rm -rf $(go env GOPATH)
