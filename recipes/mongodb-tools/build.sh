#!/bin/bash

export CGO_CFLAGS="-I${PREFIX}/include"

export CGO_LDFLAGS="-L${PREFIX}/lib"

./build.sh ssl sasl

mkdir -p ${PREFIX}/bin

mv bin/* ${PREFIX}/bin/
