#!/bin/bash

sh bootstrap.sh
./configure --prefix=$PREFIX --with-boost=no
make
make install

# don't exit on make check failure, otherwise we can't debug
set +e
make check
if [ $? -ne 0 ]; then
    check_result=$?
    echo "make check failed, printing logs for debugging:"
    echo "src/test-suite.log:"
    cat src/test-suite.log
    echo "config.log:"
    cat config.log
    exit $check_result
fi
set -e
