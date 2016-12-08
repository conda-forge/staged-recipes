#!/bin/bash

mkdir -vp ${PREFIX}/bin;

cp -v go-spatial ${PREFIX}/bin/ || exit 1;
chmod -v 755 ${PREFIX}/bin/go-spatial || exit 1;
