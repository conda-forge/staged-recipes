#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING PATO ###\n"
cd $PREFIX
# run tests
which runtests
runtests

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi
