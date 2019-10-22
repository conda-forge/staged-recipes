#!/bin/bash

mkdir -vp ${PREFIX}/bin;

cp -v example-hotrod jaeger-* ${PREFIX}/bin/ || exit 1;
chmod -v 755 ${PREFIX}/bin/* || exit 1;
