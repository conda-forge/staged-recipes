#!/bin/bash

set -x

./configure -bfd=download || {
    cat $SRC_DIR/.tmp_bfdbuild_*/tau_build.log
    cat $SRC_DIR/.tmp_bfdbuild_*/tau_configure.log
    exit 1
}


make
