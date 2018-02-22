#!/bin/bash
set -e
perl Configure.pl --backend=moar --gen-moar --prefix="$PREFIX"
make
make rakudo-test
make install
