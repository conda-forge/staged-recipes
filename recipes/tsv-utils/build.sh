#!/bin/bash

set -x

make DCOMPILER=ldc2 LDC_LTO_RUNTIME=1
make test-nobuild DCOMPILER=ldc2

cp -r bin $PREFIX
