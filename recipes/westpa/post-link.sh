#!/bin/bash

{
    cd "${PREFIX}/${PKG_NAME}-${PKG_VERSION}"
    WEST_PYTHON=$(which python2.7)
    WEST_PYTHON=$WEST_PYTHON $WEST_PYTHON .westpa_gen.py
    chmod +x westpa.sh
} >>"${PREFIX}/.messages.txt" 2>&1
