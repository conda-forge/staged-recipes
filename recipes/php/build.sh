#!/bin/bash

set -ex

./configure --prefix=$PREFIX --with-iconv=$PREFIX --with-openssl=$PREFIX --with-libxml-dir=$PREFIX
make -j${CPU_COUNT}

script -qfc "export NO_INTERACTION=1; make test; echo \$? > make_test.log"
grep -q "0" make_test.log

make install
