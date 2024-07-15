#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/${PKG_NAME}

./mill -i show dev.assembly
install -m 755 out/dev/assembly.dest/mill ${PREFIX}/bin/mill

# Create batch wrapper so that it has a .cmd extension and is recognized as executable
tee ${PREFIX}/bin/mill.cmd << EOF
call %CONDA_PREFIX%\libexec\mill\mill %*
EOF
