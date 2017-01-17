#!/bin/sh

if [ `uname` == Darwin ]; then
    LDFLAGS="$LDFLAGS -undefined dynamic_lookup -bundle"
fi


pip install --global-option install --global-option --single-version-externally-managed --global-option --record=record.txt .


