#!/bin/bash

mkdir -vp ${PREFIX}/bin;

cp -v * ${PREFIX}/bin/ || exit 1;
chmod -v 755 ${PREFIX}/bin/* || exit 1;
