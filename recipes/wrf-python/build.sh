#!/bin/sh

if [ `uname` == Darwin ]; then
    LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
fi


python setup.py install --single-version-externally-managed --record record.txt


