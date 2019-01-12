#!/bin/bash

set -e

cd ${SRC_DIR}/build_conda

# using || to quiet logs unless there is an issue
{
    make install-strip >& make_install_logs.txt
} || {
    tail -n 1000 make_install_logs.txt
    exit 1
}
