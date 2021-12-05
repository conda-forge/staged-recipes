#!/bin/bash

set -x

make DCOMPILER=ldc2 LDC_LTO_RUNTIME=1 LDC_PGO=2
make test-nobuild DCOMPILER=ldc2