#!/bin/bash

sh bootstrap.sh
./configure --prefix=$PREFIX --with-boost=no
make
make install
make check
if [ $? -ne 0 ]; then
    echo "make check failed, printing logs for debugging:"
    echo "src/test-suite.log:"
    cat src/test-suite.log
    echo "config.log:"
    cat config.log
fi