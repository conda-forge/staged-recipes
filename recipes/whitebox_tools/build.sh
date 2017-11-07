#!/bin/bash
if [ `uname` == Linux ]; then
    export SSL_CERT_FILE="$CONDA_PREFIX/ssl/cacert.pem"
fi

cd whitebox_tools
$PYTHON build.py
export WHITEBOX_TOOLS_SHARE=$CONDA_PREFIX/share/whitebox_tools
mkdir -p $WHITEBOX_TOOLS_SHARE
cp -av target/release $WHITEBOX_TOOLS_SHARE
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# conda-build is finnicky about recursive cp commands
mkdir -p $SP_DIR/whitebox_tools/data
cp -av whitebox_tools/data/* $SP_DIR/whitebox_tools/data
