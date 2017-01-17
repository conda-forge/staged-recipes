#!/bin/sh

if [ `uname` == Darwin ]; then
    LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
fi


python setup.py install --global-option --single-version-externally-managed --global-option --record=record.txt


