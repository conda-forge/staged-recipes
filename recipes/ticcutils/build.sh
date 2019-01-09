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
    echo "\n\n\nmake check failed, printing logs for debugging:\n"
    echo "\n\nsrc/test-suite.log:\n"
    cat src/test-suite.log
    echo "\n\nconfig.log:\n"
    cat config.log
    exit $check_result
fi
set -e
