#!/bin/bash

set -x

make DCOMPILER=ldc2
make test-nobuild DCOMPILER=ldc2

cp -r bin $PREFIX
