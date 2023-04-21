#!/bin/bash

# make temporary directory
mkdir -p ~/tmp
export TMPDIR=~/tmp

export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build . ${R_ARGS}
