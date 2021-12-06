#!/bin/bash

set -x

make DCOMPILER=ldc2 DFLAGS=${LDFLAGS}
make test-nobuild DCOMPILER=ldc2 DFLAGS=${LDFLAGS}

cp -r bin $PREFIX
