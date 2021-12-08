#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING PATO ###\n"
cd $PREFIX/src
if [ "$(uname)" = "Darwin" ]; then
    # copy environmentComposition
    cp $PREFIX/src/environmentComposition $PREFIX/src/volume/PATO/PATO-dev-2.3.1/data/Environments/RawData/Earth/environmentComposition
    rm -f $PREFIX/src/environmentComposition
fi
# run tests
which runtests
runtests

if [ "$(uname)" = "Darwin" ]; then
    cd $PREFIX/src
    # detach volume
    hdiutil detach volume
fi
