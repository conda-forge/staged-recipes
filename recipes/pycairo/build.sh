#! /bin/bash

set -e

if [ $(uname) = Darwin ] ; then
    # This needs to be kept the same as what was used to build Cairo, which is
    # apparently this:
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

python setup.py install
