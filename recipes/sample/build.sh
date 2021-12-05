#!/bin/bash

autoreconf -vfi
./configure || { cat config.log; false; }
make
if test "${TRAVIS_OS_NAME}" = "linux"; then
    make distcheck;
else
    make check;
fi
|| { cat test/test-suite.log sample-*/_build/test/test-suite.log; false; }