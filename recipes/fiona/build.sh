#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi

$PYTHON setup.py build_ext -I$PREFIX/include -L$PREFIX/lib -lgdal \
                 install --single-version-externally-managed --record record.txt
