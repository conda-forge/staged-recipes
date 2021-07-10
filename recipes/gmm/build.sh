#!/bin/bash

# from https://web.archive.org/web/20200225211624/http://getfem.org/gmm/install.html
# configure first using conda prefix
./configure --prefix=${PREFIX}

# now install
make install
