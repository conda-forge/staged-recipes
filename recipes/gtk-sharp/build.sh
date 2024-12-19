#!/usr/bin/env bash

set -euxo pipefail

if [[ "${target_platform}" == 'linux-*' ]]; then
   ./configure --prefix=`pkg-config --variable=prefix mono`
   make
fi
