#!/usr/bin/env bash

set +x 

# Create temporary GOPATH
make hyperkube
mv _output/bin/hyperkube $PREFIX/bin

cd $PREFIX/bin
./hyperkube  --make-symlinks

conda inspect linkages --untracked -p $PREFIX
