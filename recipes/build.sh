#!/bin/bash

set -e # Abort on error

if [[ $(uname) == 'Linux' ]]; then
    if [[ $ARCH -eq 64 ]]; then
        make -f Makefile.linux64 all install INSTDIR=$PREFIX
    else
        make -f Makefile.linux all install INSTDIR=$PREFIX
    fi
else
    make -f Makefile.mac all install INSTDIR=$PREFIX
fi
